#!/usr/bin/env bash

if [[ $# -ne 1 ]]; then
    echo "false"
    exit 1
fi

if [[ "$(id -u)" -ne 0 ]]; then
    echo "false"
    exit 1
fi

readonly new_value="$1"
readonly config_file="/etc/ssh/sshd_config"

if [[ ! -w "${config_file}" ]]; then
    echo "false"
    exit 1
fi

# Use a temp file for atomic and safer writes
temp_file=$(mktemp)
trap 'rm -f "${temp_file}"' EXIT

# Check if the line exists (commented or not) and update/add accordingly
if grep -qE '^[#[:space:]]*MaxStartups' "${config_file}"; then
    # Modify the existing line, handling commented or uncommented versions
    sed "s/^[#[:space:]]*MaxStartups.*/MaxStartups ${new_value}/" "${config_file}" > "${temp_file}"
else
    # Add the new line to a copy of the file
    cp "${config_file}" "${temp_file}"
    echo "" >> "${temp_file}"
    echo "MaxStartups ${new_value}" >> "${temp_file}"
fi

if [[ $? -ne 0 ]]; then
    echo "false"
    exit 1
fi

# Validate the new config before applying
if ! sshd -t -f "${temp_file}" &>/dev/null; then
    echo "false"
    exit 1
fi

# Atomically replace the old config file with the new one
cat "${temp_file}" > "${config_file}"
if [[ $? -ne 0 ]]; then
    echo "false"
    exit 1
fi

# Reload the sshd service and report final status
if systemctl reload sshd &>/dev/null; then
    echo "true"
else
    echo "false"
fi