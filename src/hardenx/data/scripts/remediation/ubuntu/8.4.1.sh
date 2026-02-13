#!/usr/bin/env bash

# This script must be run as root.
if [[ "$EUID" -ne 0 ]]; then
  echo "false"
  exit 1
fi

# Check for the required argument.
if [[ "$1" != "Enabled" ]]; then
  echo "false"
  exit 1
fi

# Check for required commands.
if ! command -v auditctl &> /dev/null || ! command -v augenrules &> /dev/null; then
    echo "false"
    exit 1
fi

RULE_FILE="/etc/audit/rules.d/99-sudoers.rules"
RULE1="-w /etc/sudoers -p wa -k scope"
RULE2="-w /etc/sudoers.d/ -p wa -k scope"

# auditctl output for a directory watch does not include the trailing slash.
RULE2_CHECK="-w /etc/sudoers.d -p wa -k scope"

# Check if rules are already loaded into the kernel.
rule1_loaded=$(auditctl -l | grep -Fx -- "$RULE1")
rule2_loaded=$(auditctl -l | grep -Fx -- "$RULE2_CHECK")

# If both rules are already loaded, we're done.
if [[ -n "$rule1_loaded" && -n "$rule2_loaded" ]]; then
  echo "true"
  exit 0
fi

# Ensure the rules file directory exists.
mkdir -p "$(dirname "$RULE_FILE")"

# Ensure the rules exist in the file.
if ! grep -qFx -- "$RULE1" "$RULE_FILE" 2>/dev/null; then
  echo "$RULE1" >> "$RULE_FILE"
fi

if ! grep -qFx -- "$RULE2" "$RULE_FILE" 2>/dev/null; then
  echo "$RULE2" >> "$RULE_FILE"
fi

# Load the rules from the configuration files.
if augenrules --load; then
  echo "true"
  exit 0
else
  echo "false"
  exit 1
fi