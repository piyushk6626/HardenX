#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "false"
   exit 1
fi

if [ "$#" -ne 1 ]; then
    echo "false"
    exit 1
fi

MODE=$1
RULES_FILE="/etc/audit/rules.d/audit.rules"

if [[ ! "$MODE" =~ ^[012]$ ]]; then
    echo "false"
    exit 1
fi

if [ ! -f "$RULES_FILE" ]; then
    touch "$RULES_FILE"
    if [ $? -ne 0 ]; then
        echo "false"
        exit 1
    fi
fi

if grep -q -E '^\s*-e\s+[0-9]+' "$RULES_FILE"; then
    sed -i "s/^\s*-e\s+[0-9]+/-e $MODE/" "$RULES_FILE"
else
    echo "-e $MODE" >> "$RULES_FILE"
fi

if [ $? -ne 0 ]; then
    echo "false"
    exit 1
fi

if augenrules --load &>/dev/null; then
    echo "true"
else
    echo "false"
fi