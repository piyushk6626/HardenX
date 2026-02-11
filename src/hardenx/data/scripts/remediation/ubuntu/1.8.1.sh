#!/usr/bin/env bash

set -e

# --- Globals ---
DEVICE=$1
AUDIT_DIR="/var/log/audit"
FSTAB_FILE="/etc/fstab"
TEMP_MOUNT=""
ORIGINAL_AUDITD_STATE="inactive"

# --- Functions ---
cleanup() {
    # This trap runs on any exit, success or failure
    local exit_code=$?
    
    # Unmount temp mount point if it exists and is mounted
    if [ -n "$TEMP_MOUNT" ] && mountpoint -q "$TEMP_MOUNT" &>/dev/null; then
        umount "$TEMP_MOUNT"
    fi
    
    # Remove temp mount point directory
    if [ -n "$TEMP_MOUNT" ] && [ -d "$TEMP_MOUNT" ]; then
        rmdir "$TEMP_MOUNT"
    fi

    # Attempt to restart auditd if it was active and is now stopped
    if [[ "$ORIGINAL_AUDITD_STATE" == "active" ]] && ! systemctl is-active --quiet auditd; then
         systemctl start auditd &>/dev/null
    fi
    
    # If the script failed via `set -e`, output 'false'
    if [ "$exit_code" -ne 0 ] && [ "$exit_code" -ne 127 ]; then
        # A sub-process might have already printed an error to stdout
        # This is a best-effort attempt to conform to the output requirement.
        echo "false"
    fi
}

# --- Main Logic ---
trap cleanup EXIT

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
   echo "Error: This script must be run as root." >&2
   echo "false"
   exit 1
fi

# Check for correct number of arguments
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <device>" >&2
    echo "false"
    exit 1
fi

# Validate the device path
if ! [ -b "$DEVICE" ]; then
    echo "Error: '$DEVICE' is not a valid block device." >&2
    echo "false"
    exit 1
fi

# Check if the mount point is already in fstab
if grep -qE "^\s*[^#]+\s+${AUDIT_DIR}(\s+|$)" "$FSTAB_FILE"; then
    echo "Error: An entry for '${AUDIT_DIR}' already exists in ${FSTAB_FILE}." >&2
    echo "false"
    exit 1
fi

# Check if the device is already mounted anywhere
if findmnt -n "$DEVICE" >/dev/null; then
    echo "Error: Device '$DEVICE' is already mounted." >&2
    echo "false"
    exit 1
fi

# Store original auditd state and stop it
if systemctl is-active --quiet auditd; then
    ORIGINAL_AUDITD_STATE="active"
fi
systemctl stop auditd

# Create filesystem on the new device
mkfs.ext4 -F "$DEVICE" &>/dev/null

# Create a temporary mount point
TEMP_MOUNT=$(mktemp -d)

# Mount the new partition temporarily
mount "$DEVICE" "$TEMP_MOUNT"

# Copy existing audit data if the directory exists and has content
if [ -d "$AUDIT_DIR" ] && [ -n "$(ls -A "$AUDIT_DIR")" ]; then
    rsync -ax "$AUDIT_DIR"/ "$TEMP_MOUNT"/
fi

# Unmount the temporary partition
umount "$TEMP_MOUNT"

# Backup the original audit directory if it exists
if [ -d "$AUDIT_DIR" ]; then
    mv "$AUDIT_DIR" "${AUDIT_DIR}.bak"
fi

# Create the new mount point directory
mkdir -p "$AUDIT_DIR"

# Get the UUID of the new partition
UUID=$(blkid -s UUID -o value "$DEVICE")
if [ -z "$UUID" ]; then
    echo "Error: Could not retrieve UUID for ${DEVICE}." >&2
    # Attempt to restore old directory if it was backed up
    rmdir "$AUDIT_DIR"
    if [ -d "${AUDIT_DIR}.bak" ]; then
        mv "${AUDIT_DIR}.bak" "$AUDIT_DIR"
    fi
    echo "false"
    exit 1
fi

# Backup fstab and add the new entry with security options
cp "$FSTAB_FILE" "${FSTAB_FILE}.bak-$(date +%F-%T)"
echo "UUID=${UUID}  ${AUDIT_DIR}  ext4  defaults,nodev,noexec,nosuid  0 2" >> "$FSTAB_FILE"

# Mount the partition using the new fstab entry
mount "$AUDIT_DIR"

# Restore SELinux context if applicable
if command -v restorecon &> /dev/null; then
    restorecon -Rv "$AUDIT_DIR" &>/dev/null
fi

# Restart the audit service if it was running before
if [[ "$ORIGINAL_AUDITD_STATE" == "active" ]]; then
    systemctl start auditd
fi

# Disable trap to prevent it from firing on a clean exit
trap - EXIT

# On success, script execution reaches here
echo "true"
exit 0