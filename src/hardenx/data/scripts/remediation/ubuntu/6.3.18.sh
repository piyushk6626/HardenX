#!/usr/bin/env bash

set -e

PAM_FILE="/etc/pam.d/common-password"
VALUE=$1
TMP_FILE=$(mktemp)

# Ensure cleanup of temp file on exit
trap 'rm -f "$TMP_FILE"' EXIT

# --- Validation ---
if ! [[ "$VALUE" =~ ^[0-9]+$ ]]; then
    false
    exit 1
fi

if [[ "$EUID" -ne 0 ]]; then
    false
    exit 1
fi

if [[ ! -f "$PAM_FILE" ]]; then
    false
    exit 1
fi

# --- Modification Logic ---
if grep -qE '^\s*password\s+.*\s+pam_pwhistory\.so' "$PAM_FILE"; then
    # The line exists, so we modify it in-place using awk.
    # This handles both updating an existing remember=N and adding it if missing.
    awk -v val="$VALUE" '
        /^\s*password\s+.*\s+pam_pwhistory\.so/ {
            if (sub(/remember=[0-9]+/, "remember=" val)) {
                # Replacement successful, print the modified line
                print
            } else {
                # remember= not found, append it to the line
                print $0 " remember=" val
            }
            next # Move to the next line
        }
        { print } # Print all other lines unchanged
    ' "$PAM_FILE" > "$TMP_FILE" && mv "$TMP_FILE" "$PAM_FILE"
else
    # The line does not exist, add it to the file.
    (cat "$PAM_FILE"; echo -e "password\toptional\tpam_pwhistory.so\tremember=$VALUE") > "$TMP_FILE" && mv "$TMP_FILE" "$PAM_FILE"
fi

# Check the exit status of the last command (mv)
if [ $? -eq 0 ]; then
    true
else
    false
fi