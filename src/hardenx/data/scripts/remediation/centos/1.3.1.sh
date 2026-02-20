#!/usr/bin/env bash

# This script must be run as root.

set -e

readonly STATE_ARG="mounted"
readonly FSTAB_FILE="/etc/fstab"
readonly MOUNT_POINT="/dev/shm"
readonly FSTAB_ENTRY="tmpfs /dev/shm tmpfs defaults,nodev,nosuid,noexec 0 0"

if [[ $# -ne 1 || "$1" != "$STATE_ARG" ]]; then
    false
    exit $?
fi

if [[ $EUID -ne 0 ]]; then
   false
   exit $?
fi

# Use a temp file to avoid race conditions and partial writes.
temp_fstab=$(mktemp)
trap 'rm -f "$temp_fstab"' EXIT

# Check if an entry for the mount point already exists (and is not commented out).
if grep -q "^\s*[^#].*\s${MOUNT_POINT}\s" "$FSTAB_FILE"; then
    # Entry exists, replace it in the temp file.
    awk -v mount_point="$MOUNT_POINT" -v new_entry="$FSTAB_ENTRY" \
        '$1 ~ /^#/ || $2 != mount_point {print} $2 == mount_point {print new_entry}' \
        "$FSTAB_FILE" > "$temp_fstab"
else
    # Entry does not exist, copy original and append the new entry.
    cat "$FSTAB_FILE" > "$temp_fstab"
    # Ensure the file ends with a newline before appending.
    [[ $(tail -c1 "$temp_fstab") ]] && echo >> "$temp_fstab"
    echo "$FSTAB_ENTRY" >> "$temp_fstab"
fi

# Only write to fstab if changes were made.
if ! cmp -s "$FSTAB_FILE" "$temp_fstab"; then
    cat "$temp_fstab" > "$FSTAB_FILE"
fi

# Attempt to remount /dev/shm using the (potentially new) fstab options.
mount -o remount "${MOUNT_POINT}"

true