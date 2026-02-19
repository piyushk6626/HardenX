#!/bin/bash

if grep -shv '^[[:space:]]*#' /etc/pam.d/system-auth /etc/pam.d/password-auth 2>/dev/null | grep 'pam_pwquality.so' | grep -q 'enforce_for_root'; then
    echo "enforced"
else
    echo "not enforced"
fi