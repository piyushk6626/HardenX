#!/usr/bin/env bash

if [[ $# -ne 1 ]] || [[ "$1" != "Present" ]]; then
    echo "false"
    exit 1
fi

if [[ "${EUID}" -ne 0 ]]; then
    echo "false"
    exit 1
fi

RULE_FILE="/etc/audit/rules.d/apparmor.rules"
RULE1="-w /etc/apparmor/ -p wa -k MAC-policy"
RULE2="-w /etc/apparmor.d/ -p wa -k MAC-policy"

if ! touch "$RULE_FILE" 2>/dev/null; then
    echo "false"
    exit 1
fi

if ! grep -qxF -- "$RULE1" "$RULE_FILE"; then
    if ! echo "$RULE1" >> "$RULE_FILE"; then
        echo "false"
        exit 1
    fi
fi

if ! grep -qxF -- "$RULE2" "$RULE_FILE"; then
    if ! echo "$RULE2" >> "$RULE_FILE"; then
        echo "false"
        exit 1
    fi
fi

if augenrules --load &>/dev/null; then
    echo "true"
    exit 0
else
    echo "false"
    exit 1
fi