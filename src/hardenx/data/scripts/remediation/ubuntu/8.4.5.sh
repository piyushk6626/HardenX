#!/bin/bash

if [[ "$1" != "configured" ]]; then
    echo "false"
    exit 1
fi

if [[ "$(id -u)" -ne 0 ]]; then
    echo "false"
    exit 1
fi

RULES_FILE="/etc/audit/rules.d/50-network-config.rules"
RULES_DIR=$(dirname "$RULES_FILE")

declare -a RULES_TO_ADD=(
    "-w /etc/issue -p wa -k system-locale"
    "-w /etc/issue.net -p wa -k system-locale"
    "-w /etc/hosts -p wa -k system-locale"
    "-w /etc/network/ -p wa -k system-locale"
    "-a always,exit -F arch=b64 -S sethostname -S setdomainname -k system-locale"
    "-a always,exit -F arch=b32 -S sethostname -S setdomainname -k system-locale"
)

if ! mkdir -p "$RULES_DIR"; then
    echo "false"
    exit 1
fi

if ! touch "$RULES_FILE"; then
    echo "false"
    exit 1
fi

for rule in "${RULES_TO_ADD[@]}"; do
    if ! grep -qF -- "$rule" "$RULES_FILE"; then
        if ! echo "$rule" >> "$RULES_FILE"; then
            echo "false"
            exit 1
        fi
    fi
done

if ! augenrules --load >/dev/null 2>&1; then
    echo "false"
    exit 1
fi

echo "true"
exit 0