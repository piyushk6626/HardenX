#!/usr/bin/env bash

fail() {
    echo "false"
    exit 1
}

# 1. Check for exactly one argument
if [[ $# -ne 1 ]]; then
    fail
fi

# 2. Check for root privileges
if [[ $EUID -ne 0 ]]; then
    fail
fi

# 3. Assign variables
SSHD_CONFIG="/etc/ssh/sshd_config"
MACS_ALGORITHMS="$1"
MACS_LINE="MACs ${MACS_ALGORITHMS}"

# 4. Check if config file exists
if [[ ! -f "$SSHD_CONFIG" ]]; then
    fail
fi

# 5. Update or add the MACs line
# Use grep with -q (quiet) and -E (extended regex) for the check.
# The regex matches start of line, optional whitespace, 'MACs', and one or more whitespace chars.
if grep -qE '^[[:space:]]*MACs[[:space:]]+' "$SSHD_CONFIG"; then
    # The line exists, so we replace it with sed. The 'c\' command replaces the whole matched line.
    sed -i "/^[[:space:]]*MACs[[:space:]]\+/c\\${MACS_LINE}" "$SSHD_CONFIG" || fail
else
    # The line doesn't exist, so we append it to the file.
    echo "${MACS_LINE}" >> "$SSHD_CONFIG" || fail
fi

# 6. Test the new sshd configuration syntax
sshd -t &>/dev/null || fail

# 7. Reload the sshd service
systemctl reload sshd &>/dev/null || fail

# 8. If all commands succeeded
echo "true"
exit 0