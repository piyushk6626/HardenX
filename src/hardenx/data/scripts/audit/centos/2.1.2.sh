#!/usr/bin/env bash

GRUB_CFG="/boot/grub2/grub.cfg"

# Default to Not Configured
RESULT="Not Configured"

# Check if config file exists
if [ ! -f "${GRUB_CFG}" ]; then
    echo "${RESULT}"
    exit 0
fi

# Condition 1: Check permissions and ownership
# Permissions must be 600 or more restrictive (no group/other perms)
# Owner must be root
PERMS=$(stat -c "%a" "${GRUB_CFG}")
OWNER=$(stat -c "%U" "${GRUB_CFG}")

if (( (PERMS & 0077) == 0 )) && [ "${OWNER}" == "root" ]; then
    # Condition 2: Check for a non-empty superusers line
    if grep -qE '^\s*set\s+superusers\s*=\s*".+"' "${GRUB_CFG}"; then
        RESULT="Configured"
    fi
fi

echo "${RESULT}"