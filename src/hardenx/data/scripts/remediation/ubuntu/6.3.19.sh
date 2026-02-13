#!/usr/bin/env bash

if [[ $# -ne 1 ]]; then
    echo "false"
    exit 1
fi

if ! [[ "$1" =~ ^[0-9]+$ ]]; then
    echo "false"
    exit 1
fi

REMEMBER_VALUE="$1"
TARGET_FILE="/etc/pam.d/common-password"

if ! [ -f "$TARGET_FILE" ] || ! [ -w "$TARGET_FILE" ]; then
    echo "false"
    exit 1
fi

# Check if the pam_pwhistory.so line exists
if grep -q "pam_pwhistory\.so" "$TARGET_FILE"; then
    # Line exists, check if 'remember=' parameter is also on the line
    if grep -q "pam_pwhistory\.so.*remember=" "$TARGET_FILE"; then
        # Parameter exists, update its value
        sed -i.bak "s/\(pam_pwhistory\.so.*remember=\)[0-9]*/\1$REMEMBER_VALUE/" "$TARGET_FILE"
    else
        # Line exists but without the parameter, so append it
        sed -i.bak "/pam_pwhistory\.so/s/$/ remember=$REMEMBER_VALUE/" "$TARGET_FILE"
    fi
else
    # Line does not exist, so add a new default line
    echo "password	requisite			pam_pwhistory.so remember=$REMEMBER_VALUE" >> "$TARGET_FILE"
fi

if [ $? -eq 0 ]; then
    rm -f "$TARGET_FILE.bak" >/dev/null 2>&1
    echo "true"
    exit 0
else
    # Restore backup if sed created one and failed
    if [ -f "$TARGET_FILE.bak" ]; then
        mv "$TARGET_FILE.bak" "$TARGET_FILE"
    fi
    echo "false"
    exit 1
fi