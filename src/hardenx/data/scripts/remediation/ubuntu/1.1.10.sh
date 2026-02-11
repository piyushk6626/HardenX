#!/usr/bin/env bash

if [[ "${EUID}" -ne 0 ]]; then
    false
    exit 1
fi

if [[ "$#" -ne 1 ]] || [[ "$1" != "Disabled" ]]; then
    false
    exit 1
fi

modules=(
    cramfs
    freevxfs
    jffs2
    hfs
    hfsplus
    squashfs
    udf
)

config_file="/etc/modprobe.d/disable-uncommon-fs.conf"

# Group commands to redirect all output to the config file at once.
# This operation's success is critical.
{
    for module in "${modules[@]}"; do
        echo "install $module /bin/true"
    done
} > "$config_file"

if [[ $? -ne 0 ]]; then
    false
    exit 1
fi

# Attempt to unload the modules. We ignore errors since they might not be loaded.
for module in "${modules[@]}"; do
    rmmod "$module" &>/dev/null
done

true
exit 0