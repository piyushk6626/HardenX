#!/usr/bin/env bash

set -e
set -o pipefail

readonly REQUIRED_ARG="enabled"
readonly MOUNT_POINT="/var/tmp"
readonly FSTAB_FILE="/etc/fstab"
readonly OPTIONS="noexec"

if [[ $EUID -ne 0 ]]; then
  exit 1
fi

if [[ "$1" != "$REQUIRED_ARG" ]]; then
  exit 1
fi

# Create a backup before modifying fstab
cp "$FSTAB_FILE" "${FSTAB_FILE}.bak.$(date +%s)"

if grep -qE "^\S+\s+${MOUNT_POINT}(\s+|$)" "$FSTAB_FILE"; then
  # Entry exists, ensure noexec option is present
  if ! grep -E "^\S+\s+${MOUNT_POINT}\s+" "$FSTAB_FILE" | awk '$4' | grep -q -w "$OPTIONS"; then
    awk -v mp="$MOUNT_POINT" -v opts="$OPTIONS" '
    $2 == mp {
        # Check if options column ($4) contains opts as a whole word, surrounded by commas or start/end of string
        if ($4 !~ "(^|,)(" opts ")(,|$)") {
            $4 = $4 "," opts
        }
    }
    {
        printf "%-22s %-22s %-10s %-25s %s %s\n", $1, $2, $3, $4, $5, $6
    }
    ' "$FSTAB_FILE" > "${FSTAB_FILE}.tmp" && mv "${FSTAB_FILE}.tmp" "$FSTAB_FILE"
  fi
else
  # Entry does not exist, create a new one
  if ! findmnt --mountpoint "$MOUNT_POINT" >/dev/null; then
    # /var/tmp is not a mount point, cannot proceed
    exit 1
  fi
  
  DEVICE=$(findmnt -n -o SOURCE --target "$MOUNT_POINT")
  FSTYPE=$(findmnt -n -o FSTYPE --target "$MOUNT_POINT")
  
  if [[ -z "$DEVICE" || "$DEVICE" == "tmpfs" && "$FSTYPE" == "tmpfs" ]]; then
     # Use tmpfs as a fallback if device is not found or is already tmpfs
     printf "%-22s %-22s %-10s %-25s %s %s\n" "tmpfs" "$MOUNT_POINT" "tmpfs" "defaults,${OPTIONS}" "0" "0" >> "$FSTAB_FILE"
  else
     printf "%-22s %-22s %-10s %-25s %s %s\n" "$DEVICE" "$MOUNT_POINT" "$FSTYPE" "defaults,${OPTIONS}" "0" "0" >> "$FSTAB_FILE"
  fi
fi

# Apply the setting immediately
mount -o "remount,${OPTIONS}" "$MOUNT_POINT"

true