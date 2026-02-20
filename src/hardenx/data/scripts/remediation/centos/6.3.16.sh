#!/usr/bin/env bash

# This script is designed to return true (exit 0) or false (exit 1)
# and should not produce any standard output.
exec >/dev/null 2>&1

if [[ "$1" != "Enforced" ]]; then
    exit 1
fi

REQUIRED_LINE="password requisite pam_pwquality.so try_first_pass local_users_only retry=3 authtok_type="
PAM_CONFIG_FILES=("/etc/pam.d/system-auth" "/etc/pam.d/password-auth")

# Handle systems managed by authselect
if command -v authselect >/dev/null 2>&1 && authselect check >/dev/null 2>&1; then
    if authselect current | grep -qw -- 'with-pwquality'; then
        exit 0 # Already compliant
    else
        if authselect enable-feature with-pwquality; then
            exit 0 # Successfully configured
        else
            exit 1 # Configuration failed
        fi
    fi
fi

# Handle systems not managed by authselect (manual configuration)
all_compliant=true
for config_file in "${PAM_CONFIG_FILES[@]}"; do
    if [[ ! -f "$config_file" ]]; then
        # If a standard config file doesn't exist, we can't enforce the policy.
        # This could be normal on some minimal systems, but for this script's
        # purpose, we'll consider it a state that cannot be made compliant.
        continue
    fi

    # Check if the exact, correct line is already present and not commented out
    if grep -q -E "^\s*${REQUIRED_LINE}" "$config_file"; then
        continue # This file is compliant
    fi

    # --- Attempt to fix the configuration ---
    
    # Create a backup
    cp "$config_file" "${config_file}.bak-remediation"
    if [[ $? -ne 0 ]]; then
        all_compliant=false
        break
    fi

    # Remove any existing (and likely incorrect or commented) pam_pwquality.so line
    sed -i '/pam_pwquality.so/d' "$config_file"

    # Use awk to insert the required line before the pam_unix.so password entry
    # This is a common and safe location for it in the stack.
    awk -v line="$REQUIRED_LINE" '
    BEGIN { added=0 }
    /^password\s+.*\s+pam_unix\.so/ && !added {
        print line;
        added=1;
    }
    { print }
    END { if(!added){ exit 1 } }
    ' "$config_file" > "${config_file}.tmp"

    if [[ $? -ne 0 || ! -s "${config_file}.tmp" ]]; then
         # awk failed, produced an empty file, or couldn't find the insertion point
         mv "${config_file}.bak-remediation" "$config_file" # Restore backup
         all_compliant=false
         break
    fi

    # Replace original file and restore permissions/ownership
    mv "${config_file}.tmp" "$config_file"
    chown --reference="${config_file}.bak-remediation" "$config_file"
    chmod --reference="${config_file}.bak-remediation" "$config_file"
    rm -f "${config_file}.bak-remediation"

    # Final verification for this file after attempting remediation
    if ! grep -q -E "^\s*${REQUIRED_LINE}" "$config_file"; then
        all_compliant=false
        break
    fi
done

if [[ "$all_compliant" == "true" ]]; then
    exit 0 # true
else
    exit 1 # false
fi