#!/usr/bin/env bash

APPROVED_LIST="/etc/security/approved_suid_sgid.list"

# Create a sorted list of current SUID/SGID files on the system.
# The -xdev option prevents find from traversing into other filesystems like /proc, /sys, /dev.
CURRENT_FILES=$(find / -xdev -type f \( -perm -4000 -o -perm -2000 \) 2>/dev/null | sort)

# If the approved list file does not exist or is not readable,
# then all found SUID/SGID files are considered unapproved.
if [ ! -r "$APPROVED_LIST" ]; then
    echo "$CURRENT_FILES" | wc -l
    exit 0
fi

# Create a sorted version of the approved list.
APPROVED_FILES=$(sort "$APPROVED_LIST")

# Use 'comm' to find lines that are unique to the current files list.
# -2 suppresses lines unique to the approved list.
# -3 suppresses lines common to both lists.
# The result is only the lines that are in CURRENT_FILES but not in APPROVED_FILES.
# Then, count the lines with 'wc -l'.
comm -23 <(echo "$CURRENT_FILES") <(echo "$APPROVED_FILES") | wc -l