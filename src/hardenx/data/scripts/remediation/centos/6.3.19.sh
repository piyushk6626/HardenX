#!/usr/bin/env bash

set -uo pipefail

if [[ $# -ne 1 ]] || ! [[ "$1" =~ ^[0-9]+$ ]] || [[ $EUID -ne 0 ]]; then
    echo "false"
    exit 1
fi

readonly REMEMBER_VAL="$1"
readonly PAM_FILES=("/etc/pam.d/system-auth" "/etc/pam.d/password-auth")
files_configured=0

for file in "${PAM_FILES[@]}"; do
    if [[ ! -w "$file" ]] || ! grep -q "pam_pwhistory.so" "$file"; then
        continue
    fi

    tmp_file=$(mktemp)
    if [[ ! -f "$tmp_file" ]]; then
        continue
    fi

    # Use awk to find the line, substitute existing 'remember' or append a new one.
    # Set exit status to 0 if the line was found and updated, 1 otherwise.
    awk -v val="$REMEMBER_VAL" '
    BEGIN { updated = 0 }
    /pam_pwhistory\.so/ {
        if (gsub(/remember=[0-9]+/, "remember="val)) {
            updated = 1
        } else {
            $0 = $0 " remember="val
            updated = 1
        }
    }
    { print }
    END { if (updated == 0) { exit 1 } }
    ' "$file" > "$tmp_file"

    awk_exit_code=$?

    if [[ "$awk_exit_code" -eq 0 ]] && [[ -s "$tmp_file" ]]; then
        # On success, atomically replace the original file.
        if mv "$tmp_file" "$file"; then
            ((files_configured++))
        else
            rm -f "$tmp_file" # Clean up on mv failure
        fi
    else
        rm -f "$tmp_file" # Clean up on awk failure
    fi
done

if [[ "$files_configured" -eq "${#PAM_FILES[@]}" ]]; then
    echo "true"
    exit 0
else
    echo "false"
    exit 1
fi