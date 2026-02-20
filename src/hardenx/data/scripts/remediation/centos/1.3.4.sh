#!/usr/bin/env bash

set -euo pipefail

FSTAB_FILE="/etc/fstab"
MOUNT_POINT="/dev/shm"
ACTION=${1:-}

if [[ $EUID -ne 0 ]]; then
  echo "false"
  exit 1
fi

if [[ "$ACTION" != "Enabled" && "$ACTION" != "Disabled" ]]; then
  echo "false"
  exit 1
fi

if ! grep -qP "^\S+\s+${MOUNT_POINT}\s+" "$FSTAB_FILE"; then
  echo "false"
  exit 1
fi

if [[ "$ACTION" == "Enabled" ]]; then
  # Check if noexec is already present
  if ! grep -P "^\S+\s+${MOUNT_POINT}\s+" "$FSTAB_FILE" | grep -q '\bnoexec\b'; then
    # Add noexec option. Creates a backup file /etc/fstab.bak
    sed -i.bak -E "s|(${MOUNT_POINT}\s+\S+\s+)(\S+)(.*)|\1\2,noexec\3|" "$FSTAB_FILE"
    if [[ $? -ne 0 ]]; then
      echo "false"
      exit 1
    fi
  fi
  # Remount with the new option
  if mount -o remount,noexec "$MOUNT_POINT"; then
    echo "true"
  else
    echo "false"
  fi
elif [[ "$ACTION" == "Disabled" ]]; then
  # Check if noexec is present to be removed
  if grep -P "^\S+\s+${MOUNT_POINT}\s+" "$FSTAB_FILE" | grep -q '\bnoexec\b'; then
    # Remove noexec option. Creates a backup file /etc/fstab.bak
    sed -i.bak -E -e "s/,noexec//g" -e "s/noexec,//g" "$FSTAB_FILE"
    if [[ $? -ne 0 ]]; then
      echo "false"
      exit 1
    fi
  fi
  # Remount, which will re-read fstab for options
  if mount -o remount "$MOUNT_POINT"; then
    echo "true"
  else
    echo "false"
  fi
fi