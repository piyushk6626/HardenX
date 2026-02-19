#!/bin/bash

files_to_check=("/etc/pam.d/system-auth" "/etc/pam.d/password-auth")
found_config=false
all_configs_secure=true

for file in "${files_to_check[@]}"; do
    if [ -f "$file" ]; then
        # Find lines with 'auth required pam_faillock.so' that are not commented out
        mapfile -t config_lines < <(grep -E '^\s*auth\s+required\s+pam_faillock\.so' "$file")

        if [ ${#config_lines[@]} -gt 0 ]; then
            found_config=true
            for line in "${config_lines[@]}"; do
                # Check if even_deny_root is present in the line
                if ! [[ "$line" =~ even_deny_root ]]; then
                    all_configs_secure=false
                    break 2 # Break out of both loops
                fi
            done
        fi
    fi
done

if [ "$found_config" = true ] && [ "$all_configs_secure" = true ]; then
    echo "Enabled"
else
    echo "Disabled"
fi