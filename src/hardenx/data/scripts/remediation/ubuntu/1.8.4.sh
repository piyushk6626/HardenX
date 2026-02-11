#!/usr/bin/env bash

ACTION=$1
FSTAB_FILE="/etc/fstab"
MOUNT_POINT="/var/log/audit"

# --- Helper Functions ---
fail() {
    echo "false"
    exit 1
}

succeed() {
    echo "true"
    exit 0
}

# --- Pre-flight Checks ---

if [[ "$(id -u)" -ne 0 ]]; then
    fail
fi

if [[ $# -ne 1 ]] || { [[ "$ACTION" != "Enabled" ]] && [[ "$ACTION" != "Disabled" ]]; }; then
    fail
fi

if ! grep -q -w "$MOUNT_POINT" "$FSTAB_FILE"; then
    fail
fi

# --- Main Logic ---

CURRENT_OPTS=$(awk -v mp="$MOUNT_POINT" '$2 == mp {print $4}' "$FSTAB_FILE")
if [[ -z "$CURRENT_OPTS" ]]; then
    fail
fi

HAS_NOEXEC=false
if grep -q -w "$MOUNT_POINT" "$FSTAB_FILE" | awk '$4 ~ /(^|,)noexec(,?)/ {exit 0} {exit 1}'; then
    HAS_NOEXEC=true
fi


if [[ "$ACTION" == "Enabled" ]]; then
    if [[ "$HAS_NOEXEC" == true ]]; then
        succeed
    fi

    TMP_FSTAB=$(mktemp)
    if ! awk -v mp="$MOUNT_POINT" 'BEGIN{OFS=FS="\t"} $2==mp {$4=$4",noexec"} 1' "$FSTAB_FILE" > "$TMP_FSTAB"; then
        rm -f "$TMP_FSTAB"
        fail
    fi

    # Using cat to preserve permissions of original fstab
    if ! cat "$TMP_FSTAB" > "$FSTAB_FILE"; then
        rm -f "$TMP_FSTAB"
        fail
    fi
    rm -f "$TMP_FSTAB"

    if ! mount -o remount "$MOUNT_POINT"; then
        fail
    fi

    succeed

elif [[ "$ACTION" == "Disabled" ]]; then
    if [[ "$HAS_NOEXEC" == false ]]; then
        succeed
    fi

    TMP_FSTAB=$(mktemp)
    if ! awk -v mp="$MOUNT_POINT" 'BEGIN{OFS=FS="\t"} $2==mp {gsub(/,noexec|noexec,?/, "", $4)} 1' "$FSTAB_FILE" > "$TMP_FSTAB"; then
        rm -f "$TMP_FSTAB"
        fail
    fi

    if ! cat "$TMP_FSTAB" > "$FSTAB_FILE"; then
        rm -f "$TMP_FSTAB"
        fail
    fi
    rm -f "$TMP_FSTAB"

    if ! mount -o remount "$MOUNT_POINT"; then
        fail
    fi
    
    succeed
fi

fail