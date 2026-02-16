#!/bin/bash

# This script is designed to detect duplicate UIDs in /etc/passwd
# and report them. It takes no corrective action.
# It will always exit with a status of 1 to indicate manual
# intervention is required.

DUPLICATE_UIDS=$(cut -f3 -d: /etc/passwd | sort -n | uniq -d)

if [ -n "${DUPLICATE_UIDS}" ]; then
  echo "Warning: The following duplicate UIDs were found:"
  echo "------------------------------------------------"
  for uid in ${DUPLICATE_UIDS}; do
    echo "UID: ${uid}"
    grep ":x:${uid}:" /etc/passwd | awk -F: '{print "  - User:", $1}'
  done
  echo "------------------------------------------------"
  echo "Manual intervention is required to remediate."
else
  echo "No duplicate UIDs were found."
fi

exit 1