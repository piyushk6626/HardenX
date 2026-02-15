#!/usr/bin/env bash

set -euo pipefail

if [[ "$#" -ne 1 || "$1" != "enabled" ]]; then
    false
    exit 1
fi

if [[ "${EUID}" -ne 0 ]]; then
    false
    exit 1
fi

RULE_FILE="/etc/audit/rules.d/dac-permissions.rules"
AUDIT_KEY="dac_modification_v1"

# Ensure the target directory exists
mkdir -p "$(dirname "${RULE_FILE}")" || { false; exit 1; }

# Create the file if it doesn't exist to prevent grep from failing
touch "${RULE_FILE}" || { false; exit 1; }

# Only add rules if they don't already exist to prevent duplication
if ! grep -q -- "-k ${AUDIT_KEY}" "${RULE_FILE}"; then
    RULES=$(printf '%s\n' \
      "" \
      "## Rules for DAC permission modification events" \
      "-a always,exit -F arch=b64 -S chmod,fchmod,fchmodat -F auid>=1000 -F auid!=unset -k ${AUDIT_KEY}" \
      "-a always,exit -F arch=b32 -S chmod,fchmod,fchmodat -F auid>=1000 -F auid!=unset -k ${AUDIT_KEY}" \
      "-a always,exit -F arch=b64 -S chown,fchown,fchownat,lchown -F auid>=1000 -F auid!=unset -k ${AUDIT_KEY}" \
      "-a always,exit -F arch=b32 -S chown,fchown,fchownat,lchown -F auid>=1000 -F auid!=unset -k ${AUDIT_KEY}" \
      "-a always,exit -F arch=b64 -S setxattr,fsetxattr,lsetxattr -F auid>=1000 -F auid!=unset -k ${AUDIT_KEY}" \
      "-a always,exit -F arch=b32 -S setxattr,fsetxattr,lsetxattr -F auid>=1000 -F auid!=unset -k ${AUDIT_KEY}"
    )
    # Append the rules to the specified file
    echo "${RULES}" >> "${RULE_FILE}" || { false; exit 1; }
fi

# Load the auditd rules and check for success
if augenrules --load &>/dev/null; then
    true
else
    false
fi