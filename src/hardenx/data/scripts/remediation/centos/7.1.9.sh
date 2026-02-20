#!/bin/bash

if [ "$#" -ne 1 ]; then
    exit 1
fi

remediation_failed=false

# Find all group names with GID 0 that are not 'root'
offending_groups=$(awk -F: '$3 == 0 && $1 != "root" {print $1}' /etc/group)

# If no offending groups are found, the system is compliant.
if [ -z "$offending_groups" ]; then
    # The 'true' command exits with 0
    true
    exit $?
fi

# Attempt to remove each offending group
for group_name in $offending_groups; do
    if ! groupdel "$group_name"; then
        remediation_failed=true
    fi
done

if [ "$remediation_failed" = true ]; then
    # The 'false' command exits with 1
    false
    exit $?
else
    true
    exit $?
fi