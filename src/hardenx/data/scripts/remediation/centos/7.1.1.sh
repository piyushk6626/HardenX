#!/usr/bin/env bash

LOGIN_DEFS_FILE="/etc/login.defs"
PARAM_NAME="PASS_MAX_DAYS"

# --- Pre-flight Checks ---

# Check for single, integer argument and root privileges
if [[ $# -ne 1 ]] || ! [[ "$1" =~ ^[0-9]+$ ]] || [[ $EUID -ne 0 ]]; then
    false
    exit 1
fi

# Check if target file is writable
if [[ ! -w "$LOGIN_DEFS_FILE" ]]; then
    false
    exit 1
fi

MAX_DAYS="$1"
EXIT_STATUS=1

# --- Main Logic ---

# Use a subshell to capture the exit code of sed or echo cleanly
(
  if grep -qE "^\s*${PARAM_NAME}" "$LOGIN_DEFS_FILE"; then
      # Parameter exists, so we replace the line.
      # This handles commented or uncommented lines and replaces the whole line.
      sed -i -E "s/^\s*${PARAM_NAME}.*/${PARAM_NAME}\t${MAX_DAYS}/" "$LOGIN_DEFS_FILE"
  else
      # Parameter does not exist, so we append it.
      # Ensure there's a newline before adding the parameter if the file doesn't end with one.
      [[ $(tail -c1 "$LOGIN_DEFS_FILE") ]] && echo "" >> "$LOGIN_DEFS_FILE"
      echo -e "${PARAM_NAME}\t${MAX_DAYS}" >> "$LOGIN_DEFS_FILE"
  fi
)

EXIT_STATUS=$?

if [[ ${EXIT_STATUS} -eq 0 ]]; then
    true
else
    false
fi