#!/usr/bin/env bash

if [[ "$1" != "present" ]]; then
    exit 1
fi

files_to_check=("/etc/pam.d/system-auth" "/etc/pam.d/password-auth")

for file in "${files_to_check[@]}"; do
    if [[ ! -f "$file" ]]; then
        exit 1
    fi

    if ! sed -i '/pam_pwhistory.so/ { /use_authtok/! s/$/ use_authtok/ }' "$file"; then
        exit 1
    fi
done

exit 0