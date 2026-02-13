#!/usr/bin/env bash

# This script configures pam_faillock.so to lock accounts after a specified number of failed attempts.
# It modifies /etc/pam.d/common-auth and /etc/pam.d/common-account.
# The script must be run with root privileges.

# Usage: ./configure_faillock.sh <number_of_attempts>
# Example: ./configure_faillock.sh 5

set -e

main() {
    # --- Validation ---
    if [[ $# -ne 1 ]]; then
        echo "false"
        exit 1
    fi

    local deny_value="$1"
    if ! [[ "$deny_value" =~ ^[1-9][0-9]*$ ]]; then
        echo "false"
        exit 1
    fi

    if [[ "$EUID" -ne 0 ]]; then
        echo "false"
        exit 1
    fi

    local common_auth_file="/etc/pam.d/common-auth"
    local common_account_file="/etc/pam.d/common-account"

    if [[ ! -w "$common_auth_file" || ! -w "$common_account_file" ]]; then
        echo "false"
        exit 1
    fi

    # --- Create Backups ---
    cp "$common_auth_file" "${common_auth_file}.bak.$(date +%s)"
    cp "$common_account_file" "${common_account_file}.bak.$(date +%s)"

    # --- Configuration Lines ---
    local auth_preauth_line="auth        required      pam_faillock.so preauth silent audit deny=${deny_value}"
    # The [default=die] is critical to ensure pam_unix is not tried if faillock denies access
    local auth_authfail_line="auth        [default=die] pam_faillock.so authfail silent audit deny=${deny_value}"
    # The authsucc line is needed to clear the fail count on successful login
    local auth_authsucc_line="auth        sufficient    pam_faillock.so authsucc silent audit"
    local account_required_line="account     required      pam_faillock.so"

    # --- Process common-auth ---
    # Remove any existing pam_faillock lines to ensure a clean slate
    sed -i '/pam_faillock.so/d' "$common_auth_file"

    # Insert the preauth line as the first auth module
    local first_auth_line_num
    first_auth_line_num=$(grep -n -m 1 "^auth" "$common_auth_file" | cut -d: -f1)
    if [[ -n "$first_auth_line_num" ]]; then
        sed -i "${first_auth_line_num}i ${auth_preauth_line}" "$common_auth_file"
    else
        # If no auth lines exist for some reason, append it. Unlikely case.
        echo "$auth_preauth_line" >> "$common_auth_file"
    fi

    # Insert authfail and authsucc lines after the primary authentication module (e.g., pam_unix.so)
    local primary_auth_pattern="pam_unix.so"
    if grep -q "$primary_auth_pattern" "$common_auth_file"; then
        sed -i "/${primary_auth_pattern}/a ${auth_authfail_line}\\n${auth_authsucc_line}" "$common_auth_file"
    else
        # Fallback if pam_unix is not found, append to the end.
        echo "$auth_authfail_line" >> "$common_auth_file"
        echo "$auth_authsucc_line" >> "$common_auth_file"
    fi

    # --- Process common-account ---
    # Remove any existing pam_faillock lines
    sed -i '/pam_faillock.so/d' "$common_account_file"

    # Insert the account required line as the first module
    local first_line_num
    first_line_num=$(grep -n -m 1 -v -e "^#" -e "^$" "$common_account_file" | cut -d: -f1)
    if [[ -n "$first_line_num" ]]; then
        sed -i "${first_line_num}i ${account_required_line}" "$common_account_file"
    else
        # If file is empty or only comments, add it.
        echo "$account_required_line" >> "$common_account_file"
    fi
    
    echo "true"
}

# Wrap in a subshell to catch all errors and prevent partial execution
(main "$@") || echo "false"