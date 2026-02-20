#!/bin/bash

set -e
set -o pipefail

# Check for root privileges
if [[ "${EUID}" -ne 0 ]]; then
    echo "false"
    exit 1
fi

# Check for correct number of arguments
if [[ "$#" -ne 1 ]]; then
    echo "false"
    exit 1
fi

VALUE="$1"
PARAM="net.ipv4.conf.all.secure_redirects"
CONF_FILE="/etc/sysctl.d/99-secure-redirects.conf"

# Validate that the argument is a number (0 or 1 are typical)
if ! [[ "${VALUE}" =~ ^[0-9]+$ ]]; then
    echo "false"
    exit 1
fi

# Apply the setting to the live system
if ! sysctl -w "${PARAM}=${VALUE}" >/dev/null 2>&1; then
    echo "false"
    exit 1
fi

# Ensure the configuration directory exists
mkdir -p "$(dirname "${CONF_FILE}")"

# Make the setting persistent
# Create the file if it doesn't exist
touch "${CONF_FILE}"

# Remove any existing line for this parameter to avoid duplicates
sed -i "/^\s*${PARAM}\s*=/d" "${CONF_FILE}"

# Add the new setting to the configuration file
if ! echo "${PARAM} = ${VALUE}" >> "${CONF_FILE}"; then
    # Revert live setting on failure to persist
    CURRENT_VALUE=$(sysctl -n "${PARAM}")
    if [[ "${CURRENT_VALUE}" != "${VALUE}" ]]; then
        ORIGINAL_VALUE=$(grep "^\s*${PARAM}\s*=" /proc/sys/net/ipv4/conf/all/secure_redirects 2>/dev/null || echo 1)
        sysctl -w "${PARAM}=${ORIGINAL_VALUE}" >/dev/null 2>&1
    fi
    echo "false"
    exit 1
fi

echo "true"
exit 0