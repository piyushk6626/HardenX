#!/bin/bash

if [[ "$#" -ne 1 ]] || [[ "$1" != "enforce" ]]; then
    echo "Usage: $0 enforce" >&2
    exit 1
fi

if [[ "$(id -u)" -ne 0 ]]; then
    echo "Error: This script must be run as root." >&2
    exit 1
fi

declare -A valid_shells
while IFS= read -r shell; do
    [[ -z "$shell" || "$shell" == \#* ]] && continue
    valid_shells["$shell"]=1
done < /etc/shells

all_successful=true

while IFS=: read -r username _ _ _ _ _ shell; do
    # Check if the user's shell is not in the set of valid shells
    if [[ -z "${valid_shells[$shell]}" ]]; then
        # Get password status. Format is: <username> <status> ...
        # e.g., user1 P ... (Password set) or user2 L ... (Locked)
        read -r _ status _ <<< "$(passwd -S "$username" 2>/dev/null)"
        
        # If the account is not already locked, attempt to lock it
        if [[ "$status" != "L" ]]; then
            if ! passwd -l "$username" &>/dev/null; then
                all_successful=false
            fi
        fi
    fi
done < /etc/passwd

if $all_successful; then
    echo "true"
else
    echo "false"
fi