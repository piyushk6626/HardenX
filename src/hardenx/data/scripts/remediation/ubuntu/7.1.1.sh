#!/usr/bin/env bash

# This script must be run as root
if (( EUID != 0 )); then
  false
  exit $?
fi

# Check for exactly one argument
if [[ $# -ne 1 ]]; then
  false
  exit $?
fi

# Check if the argument is a non-negative integer
readonly NEW_VALUE="$1"
if ! [[ "$NEW_VALUE" =~ ^[0-9]+$ ]]; then
  false
  exit $?
fi

readonly TARGET_FILE="/etc/login.defs"
readonly PARAM="PASS_MAX_DAYS"

# Ensure the target file exists and is writable
if [[ ! -w "$TARGET_FILE" ]]; then
  false
  exit $?
fi

# Check if the parameter already exists (commented or not)
if grep -qE "^\s*#?\s*${PARAM}" "$TARGET_FILE"; then
    # It exists, so we replace the line.
    # The -i flag modifies the file in-place.
    sed -i -E "s/^\s*#?\s*${PARAM}\s+.*/${PARAM}\t${NEW_VALUE}/" "$TARGET_FILE"
    CMD_STATUS=$?
else
    # It does not exist, so we append it to the end of the file.
    echo -e "${PARAM}\t${NEW_VALUE}" >> "$TARGET_FILE"
    CMD_STATUS=$?
fi

if [[ ${CMD_STATUS} -eq 0 ]]; then
    true
else
    false
fi