#!/usr/bin/env bash

if [[ $EUID -ne 0 ]]; then
   echo "false"
   exit 1
fi

if [[ $# -ne 1 ]]; then
    echo "false"
    exit 1
fi

ACTION="$1"
RULE_FILE="/etc/audit/rules.d/logins.rules"
RULES=(
    "-w /var/log/faillog -p wa -k logins"
    "-w /var/log/lastlog -p wa -k logins"
    "-w /var/log/tallylog -p wa -k logins"
)

reload_rules() {
    if augenrules --load &>/dev/null; then
        return 0
    else
        return 1
    fi
}

case "$ACTION" in
    enabled)
        RULE_DIR=$(dirname "$RULE_FILE")
        if [[ ! -d "$RULE_DIR" ]]; then
            mkdir -p "$RULE_DIR" || { echo "false"; exit 1; }
        fi
        touch "$RULE_FILE" || { echo "false"; exit 1; }

        for rule in "${RULES[@]}"; do
            if ! grep -qFx -- "$rule" "$RULE_FILE"; then
                if ! echo "$rule" >> "$RULE_FILE"; then
                    echo "false"
                    exit 1
                fi
            fi
        done

        if reload_rules; then
            echo "true"
        else
            echo "false"
        fi
        ;;

    disabled)
        if [[ -f "$RULE_FILE" ]]; then
            for rule in "${RULES[@]}"; do
                # Use a different delimiter for sed since rule contains slashes
                sed -i -- "\#^${rule}$#d" "$RULE_FILE" || { echo "false"; exit 1; }
            done
        fi

        if reload_rules; then
            echo "true"
        else
            echo "false"
        fi
        ;;

    *)
        echo "false"
        exit 1
        ;;
esac