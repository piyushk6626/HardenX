#!/usr/bin/env bash

set -uo pipefail

if [[ $# -ne 1 ]]; then
  echo "false"
  exit 1
fi

readonly STATE="$1"
readonly RULE_FILE="/etc/audit/rules.d/privileged.rules"

if [[ "${STATE}" != "Present" ]]; then
  echo "true"
  exit 0
fi

if [[ "${EUID}" -ne 0 ]]; then
  echo "false"
  exit 1
fi

# Ensure the parent directory exists
if ! mkdir -p "$(dirname "${RULE_FILE}")" &>/dev/null; then
  echo "false"
  exit 1
fi

# Write the auditd rules to the file
if ! cat > "${RULE_FILE}" << EOF
-a always,exit -F arch=b64 -S execve -F auid>=1000 -F auid!=-1 -k privileged
-a always,exit -F arch=b32 -S execve -F auid>=1000 -F auid!=-1 -k privileged
EOF
then
  echo "false"
  exit 1
fi

# Load the rules using augenrules
if ! augenrules --load &>/dev/null; then
  echo "false"
  exit 1
fi

echo "true"
exit 0