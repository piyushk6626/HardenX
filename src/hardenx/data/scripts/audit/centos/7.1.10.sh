#!/usr/bin/env bash

CONFIG_FILE="/etc/ssh/sshd_config"
DEFAULT_VALUE="yes"

# Keywords in sshd_config are case-insensitive.
# We look for the first uncommented occurrence of the keyword.
# The regex '^[\s\t]*' handles leading whitespace and ensures we don't match commented lines.
EFFECTIVE_VALUE=$(grep -i -E '^[[:space:]]*PermitRootLogin' "${CONFIG_FILE}" | head -n 1 | awk '{print $2}')

if [ -n "${EFFECTIVE_VALUE}" ]; then
    echo "${EFFECTIVE_VALUE}"
else
    echo "${DEFAULT_VALUE}"
fi