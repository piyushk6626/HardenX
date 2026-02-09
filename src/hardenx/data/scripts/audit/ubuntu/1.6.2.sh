#!/usr/bin/env bash

# Get mount options for /var/tmp, suppress headers and errors
# This command will have a non-zero exit code if /var/tmp is not a mount point
options=$(findmnt -n -o OPTIONS /var/tmp 2>/dev/null)

# Check if the command failed or if 'nodev' is not in the options list
if [[ $? -ne 0 ]] || ! (echo "$options" | grep -qw 'nodev'); then
    echo "disabled"
else
    echo "enabled"
fi