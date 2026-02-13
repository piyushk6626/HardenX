#!/usr/bin/env bash

if [[ $EUID -ne 0 ]]; then
   echo "false"
   exit 1
fi

if [ "$#" -ne 1 ]; then
    echo "false"
    exit 1
fi

ACTION="$1"
RULE_FILE="/etc/audit/rules.d/99-session-logging.rules"
RULES=(
    "-w /var/run/utmp -p wa -k session"
    "-w /var/log/wtmp -p wa -k logins"
    "-w /var/log/btmp -p wa -k logins"
)

case "$ACTION" in
    Enabled)
        touch "$RULE_FILE"
        for rule in "${RULES[@]}"; do
            if ! grep -qFx -- "$rule" "$RULE_FILE"; then
                echo "$rule" >> "$RULE_FILE"
            fi
        done
        ;;
    Disabled)
        if [ -f "$RULE_FILE" ]; then
            for rule in "${RULES[@]}"; do
                sed -i "\:^${rule}$:d" "$RULE_FILE"
            done
        fi
        ;;
    *)
        echo "false"
        exit 1
        ;;
esac

if augenrules --load &>/dev/null; then
    echo "true"
else
    echo "false"
fi