#!/bin/bash

if [[ "$1" != "Configured" ]]; then
    echo "false"
    exit 1
fi

if [[ $EUID -ne 0 ]]; then
    echo "false"
    exit 1
fi

RULE_FILE="/etc/audit/rules.d/deletions.rules"
RULE1="-a always,exit -F arch=b64 -S unlink,unlinkat,rename,renameat -F auid>=1000 -F auid!=-1 -F key=delete"
RULE2="-a always,exit -F arch=b32 -S unlink,unlinkat,rename,renameat -F auid>=1000 -F auid!=-1 -F key=delete"

# Group operations in a subshell with 'set -e' for atomicity.
# Any failure will cause the subshell to exit with a non-zero status.
(
    set -e
    # Ensure the directory exists
    mkdir -p "$(dirname "$RULE_FILE")"
    # Ensure the file exists for grep to read
    touch "$RULE_FILE"
    # Add rule 1 if not present
    grep -qFx -- "$RULE1" "$RULE_FILE" || echo "$RULE1" >> "$RULE_FILE"
    # Add rule 2 if not present
    grep -qFx -- "$RULE2" "$RULE_FILE" || echo "$RULE2" >> "$RULE_FILE"
) &>/dev/null

if [[ $? -eq 0 ]]; then
    echo "true"
else
    echo "false"
fi