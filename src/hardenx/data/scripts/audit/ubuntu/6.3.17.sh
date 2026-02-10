#!/bin/bash

if grep -E -q "^\s*password\s+.*\s+pam_pwquality\.so" /etc/pam.d/common-password 2>/dev/null; then
    echo "enforced"
else
    echo "not enforced"
fi