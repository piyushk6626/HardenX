#!/usr/bin/env bash

if [[ $# -ne 1 || ($1 != "present" && $1 != "absent") ]]; then
    echo "false"
    exit 1
fi

if [[ $EUID -ne 0 ]]; then
   echo "false"
   exit 1
fi

STATE="$1"
RULES_FILE="/etc/audit/rules.d/permissions.rules"

read -r -d '' RULES_TO_MANAGE <<'EOF'
-a always,exit -F arch=b64 -S chacl -F auid>=1000 -F auid!=4294967295 -k perm_mod
-a always,exit -F arch=b32 -S chacl -F auid>=1000 -F auid!=4294967295 -k perm_mod
-a always,exit -F arch=b64 -S chacl -F auid=0 -k perm_mod
-a always,exit -F arch=b32 -S chacl -F auid=0 -k perm_mod
EOF

if [[ "$STATE" == "present" ]]; then
    mkdir -p "$(dirname "$RULES_FILE")" || { echo "false"; exit 1; }
    touch "$RULES_FILE" || { echo "false"; exit 1; }

    while IFS= read -r rule; do
        if ! grep -qFx -- "$rule" "$RULES_FILE"; then
            if ! echo "$rule" >> "$RULES_FILE"; then
                echo "false"
                exit 1
            fi
        fi
    done <<< "$RULES_TO_MANAGE"

elif [[ "$STATE" == "absent" ]]; then
    if [[ -f "$RULES_FILE" ]]; then
        while IFS= read -r rule; do
            # Use | as a delimiter for sed to avoid issues with special characters in the rule
            if ! sed -i "\|^${rule}$|d" "$RULES_FILE"; then
                echo "false"
                exit 1
            fi
        done <<< "$RULES_TO_MANAGE"
    fi
fi

if ! augenrules --load >/dev/null 2>&1; then
    echo "false"
    exit 1
fi

echo "true"
exit 0