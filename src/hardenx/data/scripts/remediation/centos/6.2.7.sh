#!/usr/bin/env bash

# This script requires root privileges to modify /etc/pam.d/su
if [[ $EUID -ne 0 ]]; then
    echo "false"
    exit 1
fi

ACTION="$1"
PAM_FILE="/etc/pam.d/su"
LINE_TO_MANAGE="auth required pam_wheel.so use_uid"
# Use a regex that is flexible with whitespace
LINE_REGEX="auth\s+required\s+pam_wheel.so\s+use_uid"

# Check if the target file exists and is writable
if [[ ! -w "$PAM_FILE" ]]; then
    echo "false"
    exit 1
fi

case "$ACTION" in
    Enabled)
        # Case 1: The line is commented out. Uncomment it.
        if grep -q -E "^\s*#\s*${LINE_REGEX}" "$PAM_FILE"; then
            # The -E is for extended regex, \s+ might not be standard in basic sed
            sed -i.bak -E "s/^\s*#\s*(${LINE_REGEX})/\1/" "$PAM_FILE"
            if [[ $? -eq 0 ]]; then
                echo "true"
            else
                echo "false"
            fi
        # Case 2: The line is already present and not commented. Success.
        elif grep -q -E "^\s*${LINE_REGEX}" "$PAM_FILE"; then
            echo "true"
        # Case 3: The line does not exist at all. Add it.
        else
            # Append the line to the file.
            echo "$LINE_TO_MANAGE" >> "$PAM_FILE"
            if [[ $? -eq 0 ]]; then
                echo "true"
            else
                echo "false"
            fi
        fi
        ;;
    Disabled)
        # If the line exists and is NOT commented, comment it out.
        if grep -q -E "^\s*${LINE_REGEX}" "$PAM_FILE"; then
            sed -i.bak -E "s/^(\s*)(${LINE_REGEX})/#\1\2/" "$PAM_FILE"
            if [[ $? -eq 0 ]]; then
                echo "true"
            else
                echo "false"
            fi
        # If the line is already commented or does not exist, the state is already correct. Success.
        else
            echo "true"
        fi
        ;;
    *)
        # The provided argument was not 'Enabled' or 'Disabled'
        echo "false"
        exit 1
        ;;
esac