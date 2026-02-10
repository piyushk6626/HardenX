#!/bin/bash

# Find any host key file that does NOT have root as owner OR 600 as permissions.
# The -quit option makes find exit as soon as the first non-compliant file is found.
non_compliant_file=$(find /etc/ssh/ -maxdepth 1 -name 'ssh_host_*_key' -type f \( ! -user root -o ! -perm 600 \) -print -quit)

# If the result of the find command is an empty string, no non-compliant files were found.
if [ -z "$non_compliant_file" ]; then
    echo "true"
else
    echo "false"
fi