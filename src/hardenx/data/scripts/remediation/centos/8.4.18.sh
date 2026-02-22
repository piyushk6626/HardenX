#!/bin/bash

if [[ "$1" != "Present" ]]; then
    echo "false"
    exit 1
fi

if [[ $EUID -ne 0 ]]; then
   echo "false"
   exit 1
fi

RULE_FILE="/etc/audit/rules.d/usermod.rules"
RULE="-w /usr/sbin/usermod -p wa -k usermod"
RULES_DIR="/etc/audit/rules.d"

if ! mkdir -p "$RULES_DIR"; then
    echo "false"
    exit 1
fi

# Make script idempotent: add the rule only if it doesn't exist
if ! grep -qFx -- "$RULE" "$RULE_FILE" 2>/dev/null; then
    if ! echo "$RULE" >> "$RULE_FILE"; then
        echo "false"
        exit 1
    fi
fi

# Reload rules and output based on success/failure of the command
if augenrules --load &>/dev/null; then
    echo "true"
else
    echo "false"
fi