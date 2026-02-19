#!/bin/bash

remember_val=0
files_to_check=("/etc/pam.d/system-auth" "/etc/pam.d/password-auth")

for pam_file in "${files_to_check[@]}"; do
    if [[ -r "$pam_file" ]]; then
        result=$(grep -E '^\s*password\s+.*\s+pam_pwhistory\.so\s+' "$pam_file" | sed -n 's/.*remember=\([0-9]\+\).*/\1/p' | head -n 1)
        if [[ -n "$result" ]]; then
            remember_val="$result"
            break
        fi
    fi
done

echo "$remember_val"