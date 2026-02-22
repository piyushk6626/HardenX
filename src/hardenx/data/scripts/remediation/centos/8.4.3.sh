#!/bin/bash

if [[ $# -ne 1 ]] || [[ "$1" != "present" && "$1" != "absent" ]]; then
    echo "false"
    exit 1
fi

if [[ $EUID -ne 0 ]]; then
   echo "false"
   exit 1
fi

ACTION="$1"
RULE_FILE="/etc/audit/rules.d/audit.rules"
RULE_CONTENT="-w /var/log/sudo.log -p wa -k sudo_log_events"
RULE_DIR=$(dirname "$RULE_FILE")

reload_rules() {
    if ! augenrules --load >/dev/null 2>&1; then
        return 1
    fi
    return 0
}

case "$ACTION" in
    present)
        if [ ! -d "$RULE_DIR" ]; then
            mkdir -p "$RULE_DIR" || { echo "false"; exit 1; }
        fi
        if [ ! -f "$RULE_FILE" ]; then
            touch "$RULE_FILE" || { echo "false"; exit 1; }
        fi

        if ! grep -qFx "$RULE_CONTENT" "$RULE_FILE"; then
            echo "$RULE_CONTENT" >> "$RULE_FILE" || { echo "false"; exit 1; }
        fi

        if reload_rules; then
            echo "true"
        else
            echo "false"
        fi
        ;;

    absent)
        if [ ! -f "$RULE_FILE" ]; then
            echo "true"
            exit 0
        fi

        if grep -qFx "$RULE_CONTENT" "$RULE_FILE"; then
            # Use a different sed delimiter to avoid escaping the forward slash
            sed -i "\#^${RULE_CONTENT}$#d" "$RULE_FILE" || { echo "false"; exit 1; }
        fi

        if reload_rules; then
            echo "true"
        else
            echo "false"
        fi
        ;;
esac