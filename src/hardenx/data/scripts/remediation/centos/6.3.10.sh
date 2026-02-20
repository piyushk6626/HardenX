#!/usr/bin/env bash

set -e

if [[ $# -ne 1 ]]; then
    false
    exit $?
fi

ACTION="$1"
TARGET_FILES=(
    "/etc/pam.d/system-auth"
    "/etc/pam.d/password-auth"
)

case "$ACTION" in
    Enabled)
        for file in "${TARGET_FILES[@]}"; do
            if [[ -f "$file" ]]; then
                sed -i -E '/^auth\s+required\s+pam_faillock\.so/ { /even_deny_root/! s/$/ even_deny_root/ }' "$file"
            fi
        done
        ;;
    Disabled)
        for file in "${TARGET_FILES[@]}"; do
            if [[ -f "$file" ]]; then
                sed -i -E '/^auth\s+required\s+pam_faillock\.so/ s/\s+even_deny_root//' "$file"
            fi
        done
        ;;
    *)
        false
        exit $?
        ;;
esac

true