#!/usr/bin/env bash

set -euo pipefail

if [[ $# -ne 1 ]]; then
    echo "false"
    exit 1
fi

ACTION="$1"
MOUNT_POINT="/var/log/audit"
FSTAB_FILE="/etc/fstab"

if [[ "$ACTION" != "Enabled" && "$ACTION" != "Disabled" ]]; then
    echo "false"
    exit 1
fi

if ! grep -q -E "^\S+\s+${MOUNT_POINT}(\s+|$)" "${FSTAB_FILE}"; then
    echo "false"
    exit 1
fi

TMP_FSTAB=$(mktemp)
trap 'rm -f "$TMP_FSTAB"' EXIT

if [[ "$ACTION" == "Enabled" ]]; then
    awk -v mp="$MOUNT_POINT" '
        $2 == mp {
            if ($4 !~ /(^|,)nodev(,| |$)/) {
                $4 = $4 ",nodev"
            }
        }
        { print }
    ' "$FSTAB_FILE" > "$TMP_FSTAB"
elif [[ "$ACTION" == "Disabled" ]]; then
    awk -v mp="$MOUNT_POINT" '
        $2 == mp {
            gsub(/,nodev/, "", $4)
            gsub(/nodev,/, "", $4)
            if ($4 == "nodev") {
                $4 = "defaults"
            }
        }
        { print }
    ' "$FSTAB_FILE" > "$TMP_FSTAB"
fi

if ! cmp -s "$FSTAB_FILE" "$TMP_FSTAB"; then
    cat "$TMP_FSTAB" > "$FSTAB_FILE" || { echo "false"; exit 1; }
    mount -o remount "$MOUNT_POINT" || { echo "false"; exit 1; }
fi

echo "true"
exit 0