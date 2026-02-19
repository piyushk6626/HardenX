#!/usr/bin/env bash

# 9.2.6 

duplicates=$(cut -d: -f3 /etc/group | sort | uniq -c | awk '$1 > 1 {print $2}')

if [ -n "$duplicates" ]; then
    echo "Duplicate Group IDs found:"
    echo "$duplicates" | while read -r gid; do
        groups=$(awk -F: -v id="$gid" '$3 == id {print $1}' /etc/group | paste -sd ",")
        echo "   GID $gid is shared by groups: $groups"
    done
else
    echo "No duplicate GIDs found."
fi