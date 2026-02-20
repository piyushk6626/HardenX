#!/usr/bin/env bash

# Fail and exit
fail() {
    echo "false"
    exit 1
}

# Succeed and exit
succeed() {
    echo "true"
    exit 0
}

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
   fail
fi

# Check for correct number of arguments
if [[ $# -ne 1 ]]; then
    fail
fi

ACTION="$1"
FSTAB="/etc/fstab"
MOUNT_POINT="/var/tmp"
OPTION="nosuid"
FSTAB_TMP="${FSTAB}.tmp"

# Validate argument
if [[ "$ACTION" != "enabled" && "$ACTION" != "disabled" ]]; then
    fail
fi

# Check if /var/tmp is defined as a mount point in /etc/fstab
# We are looking for a non-commented line where the second field is exactly /var/tmp
if ! awk '$2 == mp && !/^\s*#/ {found=1; exit} END{exit !found}' mp="$MOUNT_POINT" "$FSTAB"; then
    succeed
fi

# Check if the option is already present
has_option=$(awk -v mp="$MOUNT_POINT" -v opt="$OPTION" '
$2 == mp && !/^\s*#/ {
    if (index("," $4 ",", "," opt ",")) {
        print "yes"
    }
}' "$FSTAB")

if [[ "$ACTION" == "enabled" ]]; then
    if [[ "$has_option" == "yes" ]]; then
        succeed
    fi

    # Add the option
    awk -v mp="$MOUNT_POINT" -v opt="$OPTION" '{
        if ($2 == mp && !/^\s*#/) {
            $4 = $4 "," opt
        }
        print
    }' "$FSTAB" > "$FSTAB_TMP"
    if [[ $? -ne 0 ]]; then
        rm -f "$FSTAB_TMP"
        fail
    fi

elif [[ "$ACTION" == "disabled" ]]; then
    if [[ "$has_option" != "yes" ]]; then
        succeed
    fi

    # Remove the option
    awk -v mp="$MOUNT_POINT" -v opt="$OPTION" '{
        if ($2 == mp && !/^\s*#/) {
            gsub("," opt, "", $4)
            gsub(opt ",", "", $4)
            if ($4 == opt) { $4 = "defaults" }
        }
        print
    }' "$FSTAB" > "$FSTAB_TMP"
    if [[ $? -ne 0 ]]; then
        rm -f "$FSTAB_TMP"
        fail
    fi
fi

# Atomically replace the fstab file and remount
if [ -f "$FSTAB_TMP" ]; then
    # Create a backup before replacing
    cp "$FSTAB" "${FSTAB}.bak-$(date +%s)" || fail
    mv "$FSTAB_TMP" "$FSTAB" || fail
fi

mount -o remount "$MOUNT_POINT" || fail

succeed