#!/usr/bin/env bash

# Check if the module is currently loaded.
is_loaded=$(lsmod | grep -w rds)

# Check if the module is prevented from being installed.
is_disabled=$(modprobe -n -v rds 2>/dev/null | grep -q 'install /bin/true'; echo $?)

# The module is considered "Not Available" only if it is both not loaded
# AND configured to be disabled.
if [[ -z "$is_loaded" && "$is_disabled" -eq 0 ]]; then
    echo "Not Available"
else
    echo "Available"
fi