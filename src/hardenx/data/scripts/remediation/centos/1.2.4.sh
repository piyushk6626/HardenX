#!/usr/bin/env bash



if ! grep -qE '^\s*[^#]+\s+/tmp\s' /etc/fstab; then
    echo "false"
    exit 1
fi

FSTAB_ORIG=$(< /etc/fstab)
FSTAB_MODIFIED=$(awk '
    !/^\s*#/ && $2 == "/tmp" {
        if ($4 !~ /(^|,)noexec(,?)/) {
            $4 = $4 ",noexec"
        }
    }
    { print }' /etc/fstab
)

if [[ $? -ne 0 || -z "$FSTAB_MODIFIED" ]]; then
    echo "false"
    exit 1
fi

if [[ "$FSTAB_ORIG" != "$FSTAB_MODIFIED" ]]; then
    # A temporary file is used for atomicity
    TMP_FSTAB=$(mktemp)
    if [[ $? -ne 0 ]]; then
        echo "false"
        exit 1
    fi
    echo "$FSTAB_MODIFIED" > "$TMP_FSTAB"
    
    # Create backup and replace original file
    cp /etc/fstab /etc/fstab.bak."$(date +%s)"
    if ! mv "$TMP_FSTAB" /etc/fstab; then
        echo "false"
        rm -f "$TMP_FSTAB"
        exit 1
    fi
fi

if ! mount -o remount /tmp; then
    echo "false"
    exit 1
fi

if mount | grep -E '\s/tmp\s' | grep -q '\bnoexec\b'; then
    echo "true"
    exit 0
else
    echo "false"
    exit 1
fi
