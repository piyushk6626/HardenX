#!/usr/bin/env bash

FILE1="/etc/pam.d/system-auth"
FILE2="/etc/pam.d/password-auth"
PATTERN='^\s*password\s+.*\spam_pwquality\.so'

if [[ -f "$FILE1" ]] && grep -qE "$PATTERN" "$FILE1" && \
   [[ -f "$FILE2" ]] && grep -qE "$PATTERN" "$FILE2"; then
    echo "enabled"
else
    echo "disabled"
fi