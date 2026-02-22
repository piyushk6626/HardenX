#!/usr/bin/env bash

if [[ "$1" != "Present" ]]; then
    exit 1
fi

RULE_B64="-a always,exit -F arch=b64 -S mount -F auid>=1000 -F auid!=4294967295 -k mounts"
RULE_B32="-a always,exit -F arch=b32 -S mount -F auid>=1000 -F auid!=4294967295 -k mounts"
AUDIT_RULES_DIR="/etc/audit/rules.d"
TARGET_RULE_FILE="${AUDIT_RULES_DIR}/mounts.rules"
AUDIT_LIVE_RULES_FILE="/etc/audit/audit.rules"

# Ensure the audit rules directory exists
if [ ! -d "$AUDIT_RULES_DIR" ]; then
    mkdir -p "$AUDIT_RULES_DIR"
    if [[ $? -ne 0 ]]; then
        exit 1
    fi
fi

rules_were_modified=false

# Check if the b64 rule exists in any audit rule file
if ! grep -qrsF -- "$RULE_B64" "$AUDIT_RULES_DIR" "$AUDIT_LIVE_RULES_FILE" 2>/dev/null; then
    echo "$RULE_B64" >> "$TARGET_RULE_FILE"
    if [[ $? -ne 0 ]]; then
        exit 1
    fi
    rules_were_modified=true
fi

# Check if the b32 rule exists in any audit rule file
if ! grep -qrsF -- "$RULE_B32" "$AUDIT_RULES_DIR" "$AUDIT_LIVE_RULES_FILE" 2>/dev/null; then
    echo "$RULE_B32" >> "$TARGET_RULE_FILE"
    if [[ $? -ne 0 ]]; then
        exit 1
    fi
    rules_were_modified=true
fi

if [[ "$rules_were_modified" == true ]]; then
    if command -v augenrules &>/dev/null; then
        augenrules --load
        if [[ $? -ne 0 ]]; then
            exit 1
        fi
    else
        service auditd restart || systemctl restart auditd
        if [[ $? -ne 0 ]]; then
            exit 1
        fi
    fi
fi

exit 0