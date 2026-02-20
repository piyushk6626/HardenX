#!/bin/bash

# This script manages the 'Defaults use_pty' setting in sudoers.
# It requires root privileges to run.

set -o errexit
set -o nounset
set -o pipefail

SUDOERS_FILE="/etc/sudoers.d/use_pty_override"
TARGET_SETTING="Defaults use_pty"

# Function to check if the setting is currently active and not commented out.
# Returns 0 if active, 1 if not.
is_setting_active() {
    grep -rsh "^\s*${TARGET_SETTING}" /etc/sudoers /etc/sudoers.d/ 2>/dev/null | grep -vq "^\s*#"
}

# --- Argument and Privilege Checks ---

if [[ $# -ne 1 ]] || ! [[ "$1" == "true" || "$1" == "false" ]]; then
    echo "false"
    exit 1
fi
readonly ACTION="$1"

if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
    echo "false"
    exit 1
fi

# --- Main Logic ---

if [[ "$ACTION" == "true" ]]; then
    # GOAL: Ensure the setting is active.
    if is_setting_active; then
        echo "true" # Already active, success.
        exit 0
    fi

    # Attempt to create the override file.
    # We use a subshell and '&&' to ensure all commands succeed.
    # Errors are redirected to /dev/null for cleaner execution.
    if ( echo "${TARGET_SETTING}" > "${SUDOERS_FILE}" && chmod 0440 "${SUDOERS_FILE}" ) &>/dev/null; then
        # Verify the change took effect.
        if is_setting_active; then
            echo "true"
            exit 0
        fi
    fi

    # If we reach here, creating or verifying the setting failed.
    rm -f "${SUDOERS_FILE}" &>/dev/null # Clean up any partial file.
    echo "false"
    exit 1

elif [[ "$ACTION" == "false" ]]; then
    # GOAL: Ensure the setting is NOT active.

    # First, remove our managed configuration file if it exists.
    if [[ -f "${SUDOERS_FILE}" ]]; then
        if ! rm -f "${SUDOERS_FILE}"; then
            echo "false" # Failed to remove our own file.
            exit 1
        fi
    fi

    # After removing our file, check if the setting still exists elsewhere.
    if is_setting_active; then
        # The setting is still active in a file we don't manage. Report failure.
        echo "false"
        exit 1
    else
        # The setting is successfully disabled.
        echo "true"
        exit 0
    fi
fi