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
RULES_FILE="/etc/audit/rules.d/50-identity.rules"
RULE_B64="-a always,exit -F arch=b64 -S setuid -S setgid -F auid>=1000 -F auid!=-1 -F key=identity"
RULE_B32="-a always,exit -F arch=b32 -S setuid -S setgid -F auid>=1000 -F auid!=-1 -F key=identity"

case "$ACTION" in
    enabled)
        touch "$RULES_FILE"
        if ! grep -qFx -- "$RULE_B64" "$RULES_FILE"; then
            echo "$RULE_B64" >> "$RULES_FILE"
        fi
        if ! grep -qFx -- "$RULE_B32" "$RULES_FILE"; then
            echo "$RULE_B32" >> "$RULES_FILE"
        fi
        ;;
    disabled)
        if [ -f "$RULES_FILE" ]; then
            # Use sed to remove the exact lines in-place
            sed -i -e "\#^${RULE_B64}\$#d" -e "\#^${RULE_B32}\$#d" "$RULES_FILE"
            # If the file is now empty, remove it
            if [ ! -s "$RULES_FILE" ]; then
                rm -f "$RULES_FILE"
            fi
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