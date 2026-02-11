#!/bin/bash

# Configuration
CONFIG_FILE="/etc/modprobe.d/usb-storage.conf"
MODULE_NAME="usb-storage"
DISABLE_LINE="install usb-storage /bin/true"
ACTION="$1"

# --- Validation ---

# Must be run as root
if [[ "${EUID}" -ne 0 ]]; then
    false
    exit 1
fi

# Check for exactly one argument
if [[ "$#" -ne 1 ]]; then
    false
    exit 1
fi

# --- Main Logic ---

case "${ACTION}" in
    Disabled)
        echo "${DISABLE_LINE}" > "${CONFIG_FILE}"
        if [[ "$?" -ne 0 ]]; then
            false
            exit 1
        fi
        ;;

    Enabled)
        if [[ -f "${CONFIG_FILE}" ]]; then
            # Use a different delimiter for sed since the line contains a forward slash
            sed -i "\|^${DISABLE_LINE}$|d" "${CONFIG_FILE}"
            if [[ "$?" -ne 0 ]]; then
                false
                exit 1
            fi
            # If the file is now empty, remove it for cleanliness
            if ! grep -q '[^[:space:]]' "${CONFIG_FILE}"; then
                rm -f "${CONFIG_FILE}"
                if [[ "$?" -ne 0 ]]; then
                    false
                    exit 1
                fi
            fi
        fi
        ;;

    *)
        # Invalid argument
        false
        exit 1
        ;;
esac

# --- Post-change Action ---

# If the module is currently loaded, unload it.
if lsmod | grep -q "^${MODULE_NAME}\s"; then
    rmmod "${MODULE_NAME}"
    if [[ "$?" -ne 0 ]]; then
        # Failed to unload, but the configuration change was successful.
        # Depending on requirements, this could be a failure or a warning.
        # For this script, we treat it as a failure to complete the entire operation.
        false
        exit 1
    fi
fi

# All operations succeeded
true
exit 0