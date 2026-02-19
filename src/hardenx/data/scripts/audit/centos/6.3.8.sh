#!/bin/bash

files_to_check=("/etc/pam.d/system-auth" "/etc/pam.d/password-auth")

pattern1="^auth\s+required\s+pam_faillock\.so\s+preauth"
pattern2="^auth\s+\[default=die\]\s+pam_faillock\.so\s+authfail"
pattern3="^account\s+required\s+pam_faillock\.so"

for file in "${files_to_check[@]}"; do
    if [[ ! -f "$file" ]]; then
        echo "Disabled"
        exit 0
    fi

    if ! grep -qE "$pattern1" "$file" || \
       ! grep -qE "$pattern2" "$file" || \
       ! grep -qE "$pattern3" "$file"; then
        echo "Disabled"
        exit 0
    fi
done

echo "Enabled"