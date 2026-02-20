#!/bin/bash

if [[ $# -ne 1 || "$1" != "Disabled" ]]; then
  echo "false"
  exit 1
fi

# Function to execute a systemctl command and check its status.
# It succeeds if the exit code is 0 (success) or is in the list of allowed "failure" codes.
# This allows us to ignore errors like "service not found".
execute_and_check() {
  local command="$1"
  local service="$2"
  shift 2
  local allowed_codes=("$@")

  systemctl "$command" "$service" &>/dev/null
  local exit_code=$?

  if [[ $exit_code -eq 0 ]]; then
    return 0
  fi

  for code in "${allowed_codes[@]}"; do
    if [[ $exit_code -eq "$code" ]]; then
      return 0
    fi
  done

  return 1
}

# systemctl stop returns 5 if the service is not loaded/found.
# systemctl disable returns 1 if the service is not enabled/found.
# We treat these exit codes as success for our use case.
if execute_and_check stop dovecot 5 && \
   execute_and_check disable dovecot 1 && \
   execute_and_check stop cyrus-imapd 5 && \
   execute_and_check disable cyrus-imapd 1; then
  echo "true"
  exit 0
else
  echo "false"
  exit 1
fi