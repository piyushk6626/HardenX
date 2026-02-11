#!/usr/bin/env bash

if [[ "$1" != "Present" ]]; then
    echo "false"
    exit 1
fi

# Check if /tmp is a separate partition in /etc/fstab
if ! grep -q -P '^\s*\S+\s+/tmp\s+' /etc/fstab; then
    echo "false"
    exit 1
fi

# Check if the noexec option is already present for /tmp
# Use awk for precise field matching
is_set=$(awk '$2 == "/tmp" { if ($4 ~ /(^|,)noexec(,|s*$)/) print "true"; }' /etc/fstab)

if [[ "$is_set" == "true" ]]; then
    # Option is already present in fstab, ensure it is active by remounting
    if mount -o remount /tmp &>/dev/null; then
        echo "true"
        exit 0
    else
        echo "false"
        exit 1
    fi
fi

# Add the 'noexec' option. sed replaces the 4th field with itself plus ",noexec".
# A backup file /etc/fstab.bak will be created.
if sed -i.bak -E '/^\s*\S+\s+\/tmp\s+/ s/(\S+)/\1,noexec/4' /etc/fstab; then
    # Remount /tmp to apply the change immediately
    if mount -o remount /tmp &>/dev/null; then
        rm -f /etc/fstab.bak # Clean up backup on success
        echo "true"
        exit 0
    else
        # Remount failed. Revert the change in /etc/fstab.
        mv /etc/fstab.bak /etc/fstab &>/dev/null
        echo "false"
        exit 1
    fi
else
    # The sed command failed, fstab was not modified.
    echo "false"
    exit 1
fi