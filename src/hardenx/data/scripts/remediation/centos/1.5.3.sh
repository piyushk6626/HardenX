#!/bin/bash

FSTAB_FILE="/etc/fstab"
MOUNT_POINT="/var"
REQUIRED_ARG="nosuid"
OPTION_TO_ADD="nosuid"

# Check for root privileges
if [[ "${EUID}" -ne 0 ]]; then
  false
  exit 1
fi

# Check for correct number and value of arguments
if [[ "$#" -ne 1 ]] || [[ "$1" != "${REQUIRED_ARG}" ]]; then
  false
  exit 1
fi

# Check if the mount point exists in fstab and is not commented out
if ! grep -qE "^[^#]*\s+${MOUNT_POINT}\s+" "${FSTAB_FILE}"; then
  false
  exit 1
fi

# If option is not already present, add it
if ! grep -E "^[^#]*\s+${MOUNT_POINT}\s+" "${FSTAB_FILE}" | grep -q "\b${OPTION_TO_ADD}\b"; then
  # Use a temporary file for safe editing
  TMP_FSTAB=$(mktemp)
  if [[ ! -f "$TMP_FSTAB" ]]; then
    false
    exit 1
  fi
  
  # Use awk to modify the correct line and field
  awk -v mp="$MOUNT_POINT" -v opt="$OPTION_TO_ADD" '
  $2 == mp && $1 !~ /^#/ {
      $4 = $4 "," opt
  }
  { print }
  ' "$FSTAB_FILE" > "$TMP_FSTAB"

  # Verify awk succeeded and the temp file is not empty
  if [[ $? -ne 0 ]] || [[ ! -s "$TMP_FSTAB" ]]; then
    rm -f "$TMP_FSTAB"
    false
    exit 1
  fi

  # Replace the original fstab file
  cat "$TMP_FSTAB" > "$FSTAB_FILE"
  if [[ $? -ne 0 ]]; then
      rm -f "$TMP_FSTAB"
      false
      exit 1
  fi
  rm -f "$TMP_FSTAB"
fi

# Remount the partition to apply settings
mount -o remount "${MOUNT_POINT}"
if [[ $? -ne 0 ]]; then
  false
  exit 1
fi

true
exit 0