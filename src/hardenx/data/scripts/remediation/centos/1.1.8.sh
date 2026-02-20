#!/bin/bash


STATE="$1"
MODULE="udf"
CONFIG_FILE="/etc/modprobe.d/disable-${MODULE}.conf"

if [[ "${STATE}" != "disabled" ]]; then
    echo "true"
    exit 0
fi

if [[ "$EUID" -ne 0 ]]; then
   echo "false"
   exit 1
fi

# Create the modprobe configuration file to disable the module
if ! printf "install %s /bin/true\nblacklist %s\n" "$MODULE" "$MODULE" > "$CONFIG_FILE"; then
    echo "false"
    exit 1
fi

# Unload the module if it is currently loaded
if lsmod | grep -q -w "^${MODULE}"; then
    if ! rmmod "${MODULE}"; then
        echo "false"
        exit 1
    fi
fi

echo "true"
exit 0
