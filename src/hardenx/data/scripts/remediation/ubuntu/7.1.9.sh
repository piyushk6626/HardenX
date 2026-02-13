#!/usr/bin/env bash

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <authorized_group_name>" >&2
    exit 1
fi

if [[ "$EUID" -ne 0 ]]; then
    echo "Error: This script must be run as root." >&2
    exit 1
fi

AUTHORIZED_GROUP="$1"

# Function to find the next available GID >= 1001
find_new_gid() {
    local last_gid
    last_gid=$(getent group | awk -F: '{print $3}' | sort -n | tail -1)
    
    local new_gid=$((last_gid > 1000 ? last_gid + 1 : 1001))
    
    while getent group "$new_gid" >/dev/null 2>&1; do
        new_gid=$((new_gid + 1))
    done
    echo "$new_gid"
}

# Find all offending groups with GID 0
GROUPS_TO_FIX=$(getent group 0 | awk -F: -v auth_group="$AUTHORIZED_GROUP" '$1 != auth_group {print $1}')

for group_name in $GROUPS_TO_FIX; do
    NEW_GID=$(find_new_gid)
    if [[ -z "$NEW_GID" ]]; then
        # On failure, the final check will return false
        continue
    fi
    
    # Change the group's GID
    groupmod -g "$NEW_GID" "$group_name"

    # Find users whose primary group was the one we just changed and update them
    while IFS=: read -r user_name _ _ user_gid _; do
        if [[ "$user_gid" -eq 0 ]]; then
            # If the user's name matches the group name, it's a safe bet it was their primary group
            if [[ "$user_name" == "$group_name" ]]; then
                usermod -g "$NEW_GID" "$user_name"
            fi
        fi
    done < /etc/passwd
done

# Final verification
FINAL_GID0_GROUPS=$(getent group 0 | cut -d: -f1)
FINAL_GID0_COUNT=$(echo "$FINAL_GID0_GROUPS" | wc -w)

if [[ "$FINAL_GID0_COUNT" -eq 1 ]] && [[ "$FINAL_GID0_GROUPS" == "$AUTHORIZED_GROUP" ]]; then
    echo "true"
else
    echo "false"
fi