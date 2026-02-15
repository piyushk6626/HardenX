#!/usr/bin/env bash

# Script must be run as root
if [[ $EUID -ne 0 ]]; then
   echo "false"
   exit 1
fi

STATE="$1"
RULES_FILE="/etc/audit/rules.d/50-sudo.rules"
RULE="-w /var/log/sudo.log -p wa -k sudo_log_file"
RULES_DIR=$(dirname "$RULES_FILE")

# Validate input
if [[ "$STATE" != "Enabled" && "$STATE" != "Disabled" ]]; then
    echo "false"
    exit 1
fi

# Check for required command
if ! command -v augenrules &>/dev/null; then
    echo "false"
    exit 1
fi

rule_exists() {
    if [[ ! -f "$RULES_FILE" ]]; then
        return 1
    fi
    grep -qFx -- "$RULE" "$RULES_FILE"
}

reload_rules() {
    augenrules --load &>/dev/null
}

case "$STATE" in
    Enabled)
        if rule_exists; then
            echo "true"
            exit 0
        fi

        mkdir -p "$RULES_DIR"
        if ! touch "$RULES_FILE"; then
            echo "false"
            exit 1
        fi

        if ! echo "$RULE" >> "$RULES_FILE"; then
            echo "false"
            exit 1
        fi

        if reload_rules; then
            echo "true"
        else
            echo "false"
        fi
        ;;

    Disabled)
        if ! rule_exists; then
            echo "true"
            exit 0
        fi
        
        # Using '#' as a delimiter to avoid issues with slashes in the path
        if ! sed -i "\#^${RULE}$#d" "$RULES_FILE"; then
            echo "false"
            exit 1
        fi

        if reload_rules; then
            echo "true"
        else
            echo "false"
        fi
        ;;
esac
