#!/usr/bin/env bash

RULES_FILE="/etc/audit/audit.rules"
TARGET_ARG="2"
TARGET_LINE="-e 2"

# 1. Validate input argument
if [[ $# -ne 1 || "$1" != "$TARGET_ARG" ]]; then
  echo "false"
  exit 1
fi

# 2. Check for permissions and file existence
if [[ ! -w "$RULES_FILE" ]]; then
  echo "false"
  exit 1
fi

# 3. Modify the file
op_status=1
if grep -q '^-e ' "$RULES_FILE"; then
  # A line starting with '-e ' exists, so replace it.
  sed -i "s/^-e .*/$TARGET_LINE/" "$RULES_FILE"
  op_status=$?
else
  # No line starting with '-e ' exists, so append it.
  echo "$TARGET_LINE" >> "$RULES_FILE"
  op_status=$?
fi

# 4. Report final status
if [[ $op_status -eq 0 ]]; then
  echo "true"
  exit 0
else
  echo "false"
  exit 1
fi