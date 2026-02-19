#!/bin/bash

file1="/etc/pam.d/system-auth"
file2="/etc/pam.d/password-auth"

check1=false
check2=false

if [ -f "$file1" ] && grep -q 'pam_pwhistory.so' "$file1"; then
    if grep 'pam_pwhistory.so' "$file1" | grep -q 'use_authtok'; then
        check1=true
    fi
fi

if [ -f "$file2" ] && grep -q 'pam_pwhistory.so' "$file2"; then
    if grep 'pam_pwhistory.so' "$file2" | grep -q 'use_authtok'; then
        check2=true
    fi
fi

if [ "$check1" = true ] && [ "$check2" = true ]; then
    echo "true"
else
    echo "false"
fi