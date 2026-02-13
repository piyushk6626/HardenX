#!/usr/bin/env bash

RULE_FILE="/etc/audit/rules.d/permissions.rules"
RULE_CONTENT="-w /usr/bin/setfacl -p wa -k perm_mod"
ACTION=$1

if [[ $EUID -ne 0 ]]; then
   echo "false"
   exit 1
fi

if [[ -z "$ACTION" ]]; then
    echo "false"
    exit 1
fi

case "$ACTION" in
    Enabled)
        if ! mkdir -p "$(dirname "$RULE_FILE")"; then
            echo "false"
            exit 1
        fi
        
        if ! touch "$RULE_FILE"; then
            echo "false"
            exit 1
        fi

        if ! grep -qFx -- "$RULE_CONTENT" "$RULE_FILE"; then
            if ! echo "$RULE_CONTENT" >> "$RULE_FILE"; then
                echo "false"
                exit 1
            fi
        fi
        ;;

    Disabled)
        if [ -f "$RULE_FILE" ]; then
            # Use a different delimiter for sed to avoid escaping slashes
            if ! sed -i "\|^${RULE_CONTENT}$|d" "$RULE_FILE"; then
                echo "false"
                exit 1
            fi
        fi
        ;;

    *)
        echo "false"
        exit 1
        ;;
esac

if augenrules --load >/dev/null 2>&1; then
    echo "true"
else
    echo "false"
fi