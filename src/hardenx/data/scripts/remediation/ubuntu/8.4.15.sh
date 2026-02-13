#!/bin/bash

if [ "$#" -ne 1 ] || { [ "$1" != "enabled" ] && [ "$1" != "disabled" ]; }; then
    echo "false"
    exit 1
fi

STATE="$1"
RULE_FILE="/etc/audit/rules.d/perm_mod.rules"
RULE1="-a always,exit -F path=/usr/bin/chcon -F perm=x -F auid>=1000 -F auid!=-1 -k perm_mod"
RULE2="-a always,exit -F path=/usr/bin/chcon -F perm=x -F auid=0 -k perm_mod"

if [ "$STATE" == "enabled" ]; then
    if ! printf "%s\n%s\n" "$RULE1" "$RULE2" > "$RULE_FILE"; then
        echo "false"
        exit 1
    fi
elif [ "$STATE" == "disabled" ]; then
    if [ -f "$RULE_FILE" ]; then
        if ! rm -f "$RULE_FILE"; then
            echo "false"
            exit 1
        fi
    fi
fi

if augenrules --load &>/dev/null; then
    echo "true"
else
    echo "false"
fi