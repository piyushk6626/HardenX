#!/bin/bash

RULES_FILE="/etc/audit/rules.d/99-log-deletes.rules"

if [[ "$1" != "present" ]]; then
    echo "false"
    exit 1
fi

if [[ $EUID -ne 0 ]]; then
   echo "false"
   exit 1
fi

if ! mkdir -p /etc/audit/rules.d; then
    echo "false"
    exit 1
fi

(
cat <<EOF
-a always,exit -F arch=b64 -S unlink,unlinkat,rename,renameat -F auid>=1000 -F auid!=unset -k user_deletions
-a always,exit -F arch=b32 -S unlink,unlinkat,rename,renameat -F auid>=1000 -F auid!=unset -k user_deletions
EOF
) > "$RULES_FILE"

if [[ $? -ne 0 ]]; then
    echo "false"
    exit 1
fi

if augenrules --load &>/dev/null; then
    echo "true"
    exit 0
else
    rm -f "$RULES_FILE"
    echo "false"
    exit 1
fi