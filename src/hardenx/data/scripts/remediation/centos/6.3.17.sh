#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   false
fi

if [[ $# -ne 1 || ("$1" != "enforced" && "$1" != "not enforced") ]]; then
    false
fi

ACTION="$1"
FILES=("/etc/pam.d/system-auth" "/etc/pam.d/password-auth")
OPTION="enforce_for_root"
PATTERN="pam_pwquality.so"
EXIT_CODE=0

for file in "${FILES[@]}"; do
    if ! [ -f "$file" ]; then
        EXIT_CODE=1
        continue
    fi

    if ! grep -q "$PATTERN" "$file"; then
        EXIT_CODE=1
        continue
    fi

    IS_PRESENT=$(grep "$PATTERN" "$file" | grep -c "\s$OPTION\b")

    if [[ "$ACTION" == "enforced" ]]; then
        if [[ "$IS_PRESENT" -eq 0 ]]; then
            sed -i "\|$PATTERN| s|$| $OPTION|" "$file"
            if [[ $? -ne 0 ]]; then
                EXIT_CODE=1
            fi
        fi
    elif [[ "$ACTION" == "not enforced" ]]; then
        if [[ "$IS_PRESENT" -gt 0 ]]; then
            sed -i "\|$PATTERN| s|\s\+$OPTION\b||" "$file"
            if [[ $? -ne 0 ]]; then
                EXIT_CODE=1
            fi
        fi
    fi
done

if [[ "$EXIT_CODE" -eq 0 ]]; then
    true
else
    false
fi