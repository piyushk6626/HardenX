#!/usr/bin/env bash

modules=("cramfs" "freevxfs" "jffs2" "hfs" "hfsplus" "squashfs" "udf")
not_disabled=()

for module in "${modules[@]}"; do
    # A module is NOT properly disabled if:
    # 1. The 'install /bin/true' line is MISSING from /etc/modprobe.d/ (grep fails, exit code != 0)
    # OR
    # 2. The module IS currently loaded (lsmod | grep succeeds, exit code == 0)

    if ! grep -qrs "^\s*install\s\+$module\s\+/bin/true" /etc/modprobe.d/ || lsmod | grep -q "^\s*$module\s"; then
        not_disabled+=("$module")
    fi
done

if [ ${#not_disabled[@]} -eq 0 ]; then
    echo "Disabled"
else
    (IFS=,; echo "${not_disabled[*]}")
fi