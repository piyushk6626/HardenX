#!/usr/bin/env bash

CONFIG_FILE="/etc/ssh/sshd_config"
TEMP_FILE=""

# Cleanup function to be called on script exit
cleanup() {
    if [[ -n "$TEMP_FILE" && -f "$TEMP_FILE" ]]; then
        rm -f "$TEMP_FILE"
    fi
}
trap cleanup EXIT

# --- Pre-flight Checks ---

# 1. Check for root privileges
if [[ "$(id -u)" -ne 0 ]]; then
    echo "Error: This script must be run as root." >&2
    false
    exit 1
fi

# 2. Check for exactly one argument
if [[ "$#" -ne 1 ]]; then
    echo "Usage: $0 \"<Directive to add>\"" >&2
    echo "Example: $0 \"AllowUsers admin testuser\"" >&2
    false
    exit 1
fi

# 3. Check that sshd_config exists and is readable
if [[ ! -r "$CONFIG_FILE" ]]; then
    echo "Error: Cannot read sshd config file at $CONFIG_FILE" >&2
    false
    exit 1
fi

NEW_DIRECTIVE="$1"

# --- Main Logic ---

# 1. Create a temporary file
TEMP_FILE=$(mktemp)
if [[ ! -f "$TEMP_FILE" ]]; then
    echo "Error: Failed to create temporary file." >&2
    false
    exit 1
fi

# 2. Remove existing restriction directives and write to temp file
sed -E '/^[[:space:]]*(AllowUsers|DenyUsers|AllowGroups|DenyGroups)[[:space:]]+/d' "$CONFIG_FILE" > "$TEMP_FILE"

# 3. Append the new directive to the temp file
echo "$NEW_DIRECTIVE" >> "$TEMP_FILE"

# 4. Validate the syntax of the new configuration
if ! sshd -t -f "$TEMP_FILE" &>/dev/null; then
    echo "Error: New configuration has invalid syntax according to 'sshd -t'." >&2
    echo "No changes have been made to $CONFIG_FILE." >&2
    false
    exit 1
fi

# 5. Overwrite the original configuration file
# Using 'cat >' is a safe way to overwrite while preserving permissions
if ! cat "$TEMP_FILE" > "$CONFIG_FILE"; then
    echo "Error: Failed to write updated configuration to $CONFIG_FILE." >&2
    false
    exit 1
fi

# 6. Reload the sshd service
if ! systemctl reload sshd &>/dev/null; then
    echo "Error: sshd service failed to reload. The config file was updated, but you may need to manually restart the service." >&2
    false
    exit 1
fi

true