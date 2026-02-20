#!/bin/bash

#!/bin/bash

# Ensure script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root."
    exit 1
fi

# 1️ Prevent cramfs module from loading in the future
CRAMFS_CONF="/etc/modprobe.d/cramfs.conf"
echo "install cramfs /bin/true" > "$CRAMFS_CONF"

if [[ $? -eq 0 ]]; then
    echo "Configured $CRAMFS_CONF to disable cramfs."
else
    echo "Failed to write $CRAMFS_CONF."
    exit 1
fi

# 2️ Unload cramfs if currently loaded
if lsmod | grep -qw cramfs; then
    modprobe -r cramfs
    if [[ $? -eq 0 ]]; then
        echo "Unloaded cramfs module from memory."
    else
        echo "Failed to unload cramfs module (it may be in use)."
        exit 1
    fi
else
    echo "cramfs module not loaded; no action needed."
fi

#  Verify
if lsmod | grep -qw cramfs; then
    echo "CIS Check: FAIL – cramfs module is still loaded."
    exit 1
else
    echo "CIS Check: PASS – cramfs module is disabled."
fi
