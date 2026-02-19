#!/usr/bin/env bash

modules_to_check=("cramfs" "freevxfs" "jffs2" "hfs" "hfsplus" "squashfs" "udf")

for module in "${modules_to_check[@]}"; do
    # Check if the module is configured to be disabled
    if ! grep -qrs "install ${module} /bin/true" /etc/modprobe.d/; then
        echo "Enabled"
        exit 0
    fi

    # Check if the module is currently loaded
    if lsmod | grep -wq "${module}"; then
        echo "Enabled"
        exit 0
    fi
done

echo "Disabled"
exit 0