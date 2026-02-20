#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Function to be called on script failure
handle_failure() {
    echo "false"
    exit 1
}

# Trap errors and call the failure function
trap 'handle_failure' ERR

# Ensure script is run as root
if [[ $EUID -ne 0 ]]; then
   handle_failure
fi

# Validate the positional argument
if [[ "$#" -ne 1 ]] || [[ "$1" != "disabled" ]]; then
    handle_failure
fi

# Define the configuration files to modify
CONFIG_FILES=()
if [[ -f "/etc/rsyslog.conf" ]]; then
    CONFIG_FILES+=("/etc/rsyslog.conf")
fi

if [[ -d "/etc/rsyslog.d" ]]; then
    while IFS= read -r -d $'\0' file; do
        CONFIG_FILES+=("$file")
    done < <(find /etc/rsyslog.d -name "*.conf" -type f -print0)
fi

# Define the patterns for lines to be commented out
PATTERNS=(
    '$ModLoad imudp'
    '$UDPServerRun'
    '$ModLoad imtcp'
    '$InputTCPServerRun'
)

# Iterate over each configuration file
for file in "${CONFIG_FILES[@]}"; do
    # Iterate over each pattern
    for pattern in "${PATTERNS[@]}"; do
        # Search for uncommented lines matching the pattern and comment them out in-place
        sed -i -E "s/^[[:space:]]*(${pattern})/#\1/" "$file"
    done
done

# Restart the rsyslog service to apply changes
if command -v systemctl &> /dev/null && systemctl is-active --quiet rsyslog; then
    systemctl restart rsyslog
elif command -v service &> /dev/null; then
    service rsyslog restart
else
    # Fail if no known service manager is found or service is not active
    handle_failure
fi

# If all commands succeeded, output true
echo "true"