#!/usr/bin/env bash

set -euo pipefail

# --- Configuration ---
readonly CONFIG_FILE="/etc/sysctl.d/99-yama-ptrace-scope.conf"
readonly KERNEL_PARAM="kernel.yama.ptrace_scope"

# --- Functions ---
fail() {
    echo "false"
    exit 1
}

# --- Main Script ---

# 1. Validate number of arguments
if [[ $# -ne 1 ]]; then
    fail
fi

readonly VALUE="$1"

# 2. Validate argument is a valid numerical value for this parameter (0-3)
if ! [[ "${VALUE}" =~ ^[0-3]$ ]]; then
    fail
fi

# 3. Check for root privileges
if [[ "${EUID}" -ne 0 ]]; then
    fail
fi

# 4. Apply the setting to the running configuration
# The command is wrapped in a subshell with `set -e` inherited, so it will exit on failure.
# The `|| fail` is a fallback for other potential issues.
(sysctl -w "${KERNEL_PARAM}=${VALUE}" &>/dev/null) || fail

# 5. Persist the setting across reboots
# This method is idempotent: it removes any existing line for the parameter
# and then appends the new, correct line. This handles both modification and creation.
# The block is executed in a subshell to ensure any failure within it is caught.
(
    # Ensure the directory exists
    mkdir -p "$(dirname "${CONFIG_FILE}")"
    # Remove any existing entry for our parameter to avoid duplicates
    sed -i "/^${KERNEL_PARAM}\s*=/d" "${CONFIG_FILE}" 2>/dev/null || true
    # Add the new setting
    echo "${KERNEL_PARAM} = ${VALUE}" >> "${CONFIG_FILE}"
) || fail

echo "true"
exit 0