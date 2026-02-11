#!/usr/bin/env bash

set -euo pipefail

if [[ $# -ne 1 ]] || [[ "$1" != "enabled" ]]; then
    echo "false"
    exit 1
fi

if ! findmnt --mountpoint /var &>/dev/null; then
    echo "false"
    exit 1
fi

if ! grep -qE '^\S+\s+/var\s+' /etc/fstab; then
    echo "false"
    exit 1
fi

FSTAB_TEMP=$(mktemp)
trap 'rm -f "$FSTAB_TEMP"' EXIT

awk '
$2 == "/var" {
    if (index($4, "nosuid") == 0) {
        $4 = $4 ",nosuid"
    }
}
1' /etc/fstab > "$FSTAB_TEMP"

if ! cmp -s /etc/fstab "$FSTAB_TEMP"; then
    if ! cp "$FSTAB_TEMP" /etc/fstab; then
        echo "false"
        exit 1
    fi
fi

if ! mount -o remount /var; then
    echo "false"
    exit 1
fi

echo "true"
exit 0