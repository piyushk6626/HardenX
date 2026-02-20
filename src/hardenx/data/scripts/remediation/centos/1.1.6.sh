#!/bin/bash


# Your script is correct for systems where overlayfs is a loadable module.

# On systems with built-in overlayfs, there is no remediation possible except recompiling the kernel without overlayfs, which is impractical.

CONF_FILE="/etc/modprobe.d/disable-overlayfs.conf"

if [[ "$1" != "disabled" ]]; then
    echo "false"
    exit 1
fi

if echo "install overlayfs /bin/true" > "$CONF_FILE"; then
    rmmod overlayfs &>/dev/null
    echo "true"
    exit 0
else
    echo "false"
    exit 1
fi
