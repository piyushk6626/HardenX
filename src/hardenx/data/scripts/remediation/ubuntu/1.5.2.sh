#!/usr/bin/env bash

set -euo pipefail

FSTAB="/etc/fstab"
MOUNT_POINT="/var"

if [[ $EUID -ne 0 ]]; then
    echo "false"
    exit 1
fi

if [[ $# -ne 1 ]] || [[ "$1" != "Enabled" && "$1" != "Disabled" ]]; then
    echo "false"
    exit 1
fi

if ! grep -qE "^[^#].*[[:space:]]${MOUNT_POINT}([[:space:]]|$)" "$FSTAB"; then
    echo "false"
    exit 1
fi

STATE="$1"
TMP_FSTAB=$(mktemp)
trap 'rm -f "$TMP_FSTAB"' EXIT

case "$STATE" in
    Enabled)
        awk -v mount_point="$MOUNT_POINT" '
        $2 == mount_point && !/^#/ {
            if ($4 !~ /(^|,)nodev(,| |$)/) {
                $4 = $4 ",nodev"
            }
        }
        { print }
        ' "$FSTAB" > "$TMP_FSTAB"
        ;;
    Disabled)
        awk -v mount_point="$MOUNT_POINT" '
        $2 == mount_point && !/^#/ {
            n = split($4, opts, ",");
            new_opts = "";
            sep = "";
            for (i=1; i<=n; i++) {
                if (opts[i] != "nodev") {
                    new_opts = new_opts sep opts[i];
                    sep = ",";
                }
            }
            if (new_opts == "") {
                $4 = "defaults";
            } else {
                $4 = new_opts;
            }
        }
        { print }
        ' "$FSTAB" > "$TMP_FSTAB"
        ;;
esac

if ! cmp -s "$FSTAB" "$TMP_FSTAB"; then
    cp "$FSTAB" "$FSTAB.bak"
    cat "$TMP_FSTAB" > "$FSTAB"
    if mount -o remount "$MOUNT_POINT" &>/dev/null; then
        rm -f "$FSTAB.bak"
        echo "true"
        exit 0
    else
        mv "$FSTAB.bak" "$FSTAB"
        mount -o remount "$MOUNT_POINT" &>/dev/null
        echo "false"
        exit 1
    fi
else
    echo "true"
    exit 0
fi