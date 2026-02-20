#!/usr/bin/env bash

# This script must be run with root privileges.

main() {
    # 1. Validate input
    if [[ $# -ne 1 ]] || [[ "$1" != "yes" && "$1" != "no" ]]; then
        return 1
    fi

    local new_value="$1"
    local config_file="/etc/ssh/sshd_config"
    local param="GSSAPIAuthentication"

    # 2. Check if the config file exists and is writable
    if [[ ! -f "$config_file" ]] || [[ ! -w "$config_file" ]]; then
        return 1
    fi

    # 3. Modify the configuration file
    # If the parameter exists (commented or not), replace the line.
    if grep -qE "^\s*#?\s*${param}\s+" "$config_file"; then
        # Use a regex that correctly handles different spacing and comments
        sed -i -E "s/^\s*#?\s*${param}.*/${param} ${new_value}/" "$config_file"
    else
        # If the parameter does not exist, append it to the end of the file.
        echo "" >> "$config_file"
        echo "${param} ${new_value}" >> "$config_file"
    fi

    # Check if the previous command succeeded
    if [[ $? -ne 0 ]]; then
        return 1
    fi

    # 4. Reload or restart the SSH service
    # Suppress output to keep the script's final output clean.
    if command -v systemctl &>/dev/null; then
        # Try sshd.service first, then ssh.service as a fallback
        if ! (systemctl reload-or-restart sshd.service &>/dev/null || systemctl reload-or-restart ssh.service &>/dev/null); then
            return 1
        fi
    elif command -v service &>/dev/null; then
        # Fallback for older systems using the 'service' command
        if ! (service sshd restart &>/dev/null || service ssh restart &>/dev/null); then
            return 1
        fi
    else
        # If no known service manager is found, we cannot apply changes.
        return 1
    fi

    return 0
}

# Execute the main function and output true/false based on its exit code.
if main "$@"; then
    echo "true"
else
    echo "false"
fi