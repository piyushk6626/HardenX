#!/usr/bin/env bash

fail() {
    echo "false"
    exit 1
}

trap fail ERR SIGHUP SIGINT SIGTERM

if [[ "${EUID}" -ne 0 ]]; then
    echo "false"
    exit 1
fi

if [[ "$#" -ne 1 ]] || [[ -z "$1" ]]; then
    echo "false"
    exit 1
fi

KEX_ALGORITHMS="$1"
SSH_CONFIG="/etc/ssh/sshd_config"

if [[ ! -f "${SSH_CONFIG}" ]] || [[ ! -w "${SSH_CONFIG}" ]]; then
    fail
fi

# Use sed to delete any existing KexAlgorithms line (commented or not).
# The .bak extension creates a backup file.
sed -i.bak -E '/^[[:space:]]*#?[[:space:]]*KexAlgorithms[[:space:]]+/d' "${SSH_CONFIG}"

# Add the new KexAlgorithms setting to the end of the file.
echo "KexAlgorithms ${KEX_ALGORITHMS}" >> "${SSH_CONFIG}"

# Test the new configuration syntax.
# sshd -t will exit with a non-zero status if the syntax is invalid, triggering the trap.
sshd -t &>/dev/null

# Restart the SSH service to apply changes.
# This logic attempts to use systemctl, falling back to the service command.
if command -v systemctl &> /dev/null; then
    systemctl restart sshd.service || systemctl restart ssh.service
elif command -v service &> /dev/null; then
    service sshd restart || service ssh restart
else
    # If no service manager is found, consider it a failure.
    fail
fi

# If all commands succeeded, remove the backup and report success.
rm -f "${SSH_CONFIG}.bak"
echo "true"
exit 0