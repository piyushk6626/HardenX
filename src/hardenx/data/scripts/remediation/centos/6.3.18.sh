#!/bin/bash

if [[ $# -ne 1 ]] || ! [[ "$1" =~ ^[0-9]+$ ]]; then
    echo "false"
    exit 1
fi

remember_value="$1"
pam_files=("/etc/pam.d/system-auth" "/etc/pam.d/password-auth")
success=true

for file in "${pam_files[@]}"; do
    if [[ ! -f "$file" ]] || [[ ! -w "$file" ]]; then
        success=false
        break
    fi

    # Check if pam_pwhistory.so is configured in the password stack
    if ! grep -q -E '^\s*password\s+.*\s+pam_pwhistory\.so' "$file"; then
        success=false
        break
    fi

    # Check if 'remember=' option already exists on the line
    if grep -q -E '^\s*password\s+.*\s+pam_pwhistory\.so\s+.*remember=' "$file"; then
        # It exists, so replace its value, preserving other options
        sed -i -E "s/^(.*\s+pam_pwhistory\.so\s+.*remember=)[0-9]+(.*)$/\1${remember_value}\2/" "$file"
        if [[ $? -ne 0 ]]; then
            success=false
            break
        fi
    else
        # It doesn't exist, so append it to the end of the line
        sed -i -E "/^\s*password\s+.*\s+pam_pwhistory\.so/ s/$/ remember=${remember_value}/" "$file"
        if [[ $? -ne 0 ]]; then
            success=false
            break
        fi
    fi
done

echo "$success"
if [[ "$success" = true ]]; then
    exit 0
else
    exit 1
fi