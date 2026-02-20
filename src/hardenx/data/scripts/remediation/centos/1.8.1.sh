#!/usr/bin/env bash

set -euo pipefail

readonly DEVICE_PATH="${1-}"
readonly MOUNT_POINT="/var/log/audit"
readonly FS_TYPE="ext4"
readonly MOUNT_OPTIONS="nodev,nosuid"
readonly FSTAB_FILE="/etc/fstab"
readonly AUDIT_SERVICE="auditd.service"
readonly OLD_DATA_DIR="/var/log/audit.old"

main() {
    # --- Pre-flight Checks ---
    if [[ "$(id -u)" -ne 0 ]]; then
        echo "Error: This script must be run as root." >&2
        return 1
    fi

    if [[ -z "$DEVICE_PATH" ]]; then
        echo "Error: Missing required argument: block device path (e.g., /dev/sdb1)." >&2
        echo "Usage: $0 <device_path>" >&2
        return 1
    fi

    if [[ ! -b "$DEVICE_PATH" ]]; then
        echo "Error: Device '$DEVICE_PATH' is not a valid block device." >&2
        return 1
    fi

    if findmnt --mountpoint "$MOUNT_POINT" &>/dev/null; then
        echo "Error: '$MOUNT_POINT' is already a mount point." >&2
        return 1
    fi

    # --- Execution ---

    echo "Stopping auditd service..." >&2
    if ! systemctl is-active --quiet "$AUDIT_SERVICE"; then
        echo "Warning: auditd service is not running." >&2
    else
        systemctl stop "$AUDIT_SERVICE"
    fi

    mkdir -p "$MOUNT_POINT"
    mkdir -p "$OLD_DATA_DIR"

    echo "Moving existing audit data to a temporary location..." >&2
    # Move files only if the directory is not empty
    if [ -n "$(ls -A "$MOUNT_POINT" 2>/dev/null)" ]; then
        mv "$MOUNT_POINT"/* "$OLD_DATA_DIR"/
    fi

    echo "Backing up ${FSTAB_FILE} and adding new entry..." >&2
    cp "$FSTAB_FILE" "${FSTAB_FILE}.bak.$(date +%F-%T)"
    local fstab_entry
    fstab_entry="$(blkid -o value -s UUID "${DEVICE_PATH}")"
    echo "UUID=${fstab_entry} ${MOUNT_POINT} ${FS_TYPE} ${MOUNT_OPTIONS} 0 2" >> "$FSTAB_FILE"

    echo "Mounting the new partition at ${MOUNT_POINT}..." >&2
    systemctl daemon-reload
    mount -o "${MOUNT_OPTIONS}" "$MOUNT_POINT"

    echo "Restoring audit data to the new partition..." >&2
    if [ -n "$(ls -A "$OLD_DATA_DIR" 2>/dev/null)" ]; then
        mv "$OLD_DATA_DIR"/* "$MOUNT_POINT"/
    fi
    rmdir "$OLD_DATA_DIR"

    echo "Setting correct permissions on ${MOUNT_POINT}..." >&2
    chmod 0700 "$MOUNT_POINT"
    restorecon -R "$MOUNT_POINT"

    echo "Restarting auditd service..." >&2
    systemctl start "$AUDIT_SERVICE"

    echo "Configuration complete." >&2
}

if main "$@"; then
    true
else
    false
fi