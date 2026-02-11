#!/bin/bash

# Define the configuration file path
CONF_FILE="/etc/modprobe.d/disable-overlayfs.conf"
ACTION="$1"

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
   echo "false"
   exit 1
fi

# Validate input argument
if [[ "$ACTION" != "Enabled" && "$ACTION" != "Disabled" ]]; then
    echo "false"
    exit 1
fi

# Main logic
case "$ACTION" in
    Disabled)
        # Create the modprobe configuration file to disable overlayfs
        if ! echo "install overlayfs /bin/true" > "$CONF_FILE"; then
            echo "false"
            exit 1
        fi

        # If the module is currently loaded, try to remove it
        if lsmod | grep -q "^overlay\s"; then
            if ! rmmod overlayfs; then
                # If rmmod fails, it's a failure state, but we've already set the conf file
                # so the primary goal is achieved for next boot. For immediate state, it's a failure.
                echo "false"
                exit 1
            fi
        fi
        ;;

    Enabled)
        # Remove the configuration file if it exists
        if ! rm -f "$CONF_FILE"; then
            echo "false"
            exit 1
        fi
        ;;
esac

echo "true"
exit 0