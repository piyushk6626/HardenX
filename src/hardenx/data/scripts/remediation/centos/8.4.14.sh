#!/bin/bash

RULE_FILE="/etc/audit/rules.d/selinux-policy.rules"
RULE_CONTENT="-w /etc/selinux/ -p wa -k MAC-policy"
ACTION=$1

if [[ $EUID -ne 0 ]]; then
   echo "false"
   exit 1
fi

if [[ $# -ne 1 ]]; then
    echo "false"
    exit 1
fi

reload_rules() {
    if augenrules --load &>/dev/null; then
        return 0
    else
        return 1
    fi
}

case "$ACTION" in
    enabled)
        if grep -qFx -- "$RULE_CONTENT" "$RULE_FILE" 2>/dev/null; then
            echo "true"
            exit 0
        fi

        if ! echo "$RULE_CONTENT" >> "$RULE_FILE"; then
            echo "false"
            exit 1
        fi

        if reload_rules; then
            echo "true"
        else
            echo "false"
        fi
        ;;
    disabled)
        if [ ! -f "$RULE_FILE" ] || ! grep -qFx -- "$RULE_CONTENT" "$RULE_FILE"; then
            echo "true"
            exit 0
        fi

        if ! sed -i "\|^${RULE_CONTENT}$|d" "$RULE_FILE"; then
            echo "false"
            exit 1
        fi

        if [ ! -s "$RULE_FILE" ]; then
            if ! rm "$RULE_FILE"; then
                echo "false"
                exit 1
            fi
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