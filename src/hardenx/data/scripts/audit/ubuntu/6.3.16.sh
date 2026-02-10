#!/bin/bash

if [[ ! -f "/etc/pam.d/common-password" ]]; then
    echo "disabled"
    exit 0
fi

if grep -E -q '^[[:space:]]*[^#]+pam_pwquality\.so' "/etc/pam.d/common-password"; then
    echo "enabled"
else
    echo "disabled"
fi