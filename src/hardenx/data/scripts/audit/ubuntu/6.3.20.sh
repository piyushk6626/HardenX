#!/bin/bash

if grep 'pam_pwhistory.so' /etc/pam.d/common-password 2>/dev/null | grep -q 'use_authtok'; then
    echo "Present"
else
    echo "Absent"
fi