#!/bin/bash

readonly PARAM="net.ipv4.icmp_echo_ignore_broadcasts"
readonly CONF_FILE="/etc/sysctl.d/99-icmp-ignore-broadcasts.conf"

# Check for root privileges
if [[ "${EUID}" -ne 0 ]]; then
    echo "false"
    exit 1
fi

# Validate input argument
if [[ "$#" -ne 1 ]] || ! [[ "$1" =~ ^[01]$ ]]; then
    echo "false"
    exit 1
fi

readonly DESIRED_STATE="$1"

# Set runtime value
if ! sysctl -w "${PARAM}=${DESIRED_STATE}" &>/dev/null; then
    echo "false"
    exit 1
fi

# Set persistent value
# Use a temporary file for a safe, atomic write.
TMP_FILE=$(mktemp)
if [[ $? -ne 0 ]]; then
    echo "false"
    exit 1
fi

# Ensure we clean up the temp file on exit
trap 'rm -f "$TMP_FILE"' EXIT

# Create conf directory if it doesn't exist
mkdir -p "$(dirname "${CONF_FILE}")"

# Filter out the old setting if the file exists
if [[ -f "${CONF_FILE}" ]]; then
    grep -v "^\s*${PARAM}\s*=" "${CONF_FILE}" > "${TMP_FILE}"
fi

# Add the new setting
echo "${PARAM} = ${DESIRED_STATE}" >> "${TMP_FILE}"

# Atomically replace the old config file with the new one
if ! mv "${TMP_FILE}" "${CONF_FILE}"; then
    echo "false"
    exit 1
fi

# Ensure correct permissions
chmod 644 "${CONF_FILE}"

# Explicitly remove trap before successful exit
trap - EXIT

echo "true"