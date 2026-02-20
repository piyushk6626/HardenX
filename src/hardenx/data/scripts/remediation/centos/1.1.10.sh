#!/usr/bin/env bash


if (( EUID != 0 )); then
    echo "false"
    exit 1
fi

CONFIG_FILE="/etc/modprobe.d/unused_filesystems.conf"
MODULES=(
    "cramfs"
    "freevxfs"
    "jffs2"
    "hfs"
    "hfsplus"
    "squashfs"
    "udf"
)

# Use a subshell to group write operations. If any fail, the exit code will be non-zero.
(
    # Truncate or create the file
    > "$CONFIG_FILE"
    # Append the configuration for each module
    for mod in "${MODULES[@]}"; do
        echo "install $mod /bin/true" >> "$CONFIG_FILE"
    done
)

# Check if the file creation/writing succeeded
if [[ $? -ne 0 ]]; then
    echo "false"
    exit 1
fi

# Attempt to unload modules; suppress errors if they are not loaded or in use
for mod in "${MODULES[@]}"; do
    rmmod "$mod" &>/dev/null
done

echo "true"
exit 0
