#!/bin/bash

# Function to print 'false' and exit on failure
handle_error() {
    echo "false"
    exit 1
}

# Ensure script is run as root
if [[ "$EUID" -ne 0 ]]; then
  handle_error
fi

# Check for exactly one argument
if [ "$#" -ne 1 ]; then
  handle_error
fi

NEW_VALUE="$1"
CONFIG_FILE="/etc/ssh/sshd_config"

# Check if the config file exists and is a regular file
if [ ! -f "$CONFIG_FILE" ]; then
  handle_error
fi

# Use a temporary file for sed to ensure atomicity and handle permissions
TMP_FILE=$(mktemp) || handle_error
trap 'rm -f "$TMP_FILE"' EXIT

# Check if the PermitRootLogin line exists (commented or not)
if grep -qE "^\s*#?\s*PermitRootLogin" "$CONFIG_FILE"; then
  # Line exists, so replace it
  sed "s/^\s*#?\s*PermitRootLogin.*/PermitRootLogin $NEW_VALUE/" "$CONFIG_FILE" > "$TMP_FILE" || handle_error
else
  # Line does not exist, so append it
  cp "$CONFIG_FILE" "$TMP_FILE" || handle_error
  echo "PermitRootLogin $NEW_VALUE" >> "$TMP_FILE" || handle_error
fi

# Replace original file with the modified temporary file
cat "$TMP_FILE" > "$CONFIG_FILE" || handle_error

# Restart the sshd service
if command -v systemctl &>/dev/null; then
  systemctl restart sshd || handle_error
elif command -v service &>/dev/null; then
  service sshd restart || handle_error
else
  # Could not find a known service manager
  handle_error
fi

# If all commands succeeded, print 'true'
echo "true"