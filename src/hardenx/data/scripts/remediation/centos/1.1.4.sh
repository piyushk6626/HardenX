#!/bin/bash


CONFIG_FILE="/etc/modprobe.d/hfsplus.conf"

# Create the modprobe config file to prevent loading.
# If this fails (e.g., due to permissions), the script will exit with an error.
echo 'install hfsplus /bin/true' > "$CONFIG_FILE"
if [[ $? -ne 0 ]]; then
    echo "false"
    exit 1
fi

# Check if the module is currently loaded.
if lsmod | grep -wq "hfsplus"; then
    # If loaded, attempt to unload it.
    rmmod hfsplus
    if [[ $? -ne 0 ]]; then
        # If rmmod fails, the configuration is still in place,
        # but the full operation was not successful.
        echo "false"
        exit 1
    fi
fi

echo "true"
exit 0
