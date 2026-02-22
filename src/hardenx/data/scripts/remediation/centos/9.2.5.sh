#!/bin/bash

# This script checks for duplicate UIDs in /etc/passwd and logs the findings.
# It takes one argument: the expected number of duplicate UID groups (should be 0).
# It returns true (exit 0) if the number of duplicate UID groups matches the argument.
# It returns false (exit 1) and logs details if they do not match.

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <expected_duplicate_uid_group_count>" >&2
    exit 2
fi

expected_duplicates="$1"

# Use awk to find duplicate UIDs and the users associated with them.
# The output will be one line for each duplicate UID group.
duplicate_report=$(awk -F: '
{
    count[$3]++;
    users[$3]=users[$3] " " $1;
}
END {
    for (uid in count) {
        if (count[uid] > 1) {
            # Trim the leading space from the user list before printing
            sub(/^ /, "", users[uid]);
            print "Duplicate UID " uid " is assigned to users: " users[uid];
        }
    }
}' /etc/passwd)

# Count the number of duplicate UID groups found.
if [ -z "$duplicate_report" ]; then
    found_duplicates=0
else
    found_duplicates=$(echo "$duplicate_report" | wc -l)
fi

# Compare the number of found duplicate groups with the expected number.
if [ "$found_duplicates" -eq "$expected_duplicates" ]; then
    exit 0  # Return true
else
    echo "Audit Failed: Found ${found_duplicates} group(s) of duplicate UIDs."
    echo "$duplicate_report"
    exit 1  # Return false
fi