#!/bin/bash

if [[ $# -ne 1 ]] || [[ "$1" != "present" ]]; then
    echo "false"
    exit 1
fi

if [[ $EUID -ne 0 ]]; then
   echo "false"
   exit 1
fi

RULE_FILE="/etc/audit/rules.d/modules.rules"
RULES_CONTENT=$(cat <<EOF
-w /sbin/insmod -p x -k modules
-w /sbin/rmmod -p x -k modules
-w /sbin/modprobe -p x -k modules
-a always,exit -F arch=b64 -S init_module -S delete_module -k modules
-a always,exit -F arch=b32 -S init_module -S delete_module -k modules
EOF
)

# Create/overwrite the rule file
echo "$RULES_CONTENT" > "$RULE_FILE"
if [[ $? -ne 0 ]]; then
    echo "false"
    exit 1
fi

# Load the rules from the rules directory
if augenrules --load &>/dev/null; then
    echo "true"
else
    echo "false"
fi