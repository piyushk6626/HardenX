#!/bin/bash

if grep -qE '^[[:space:]]*auth.*pam_unix\.so' /etc/pam.d/system-auth /etc/pam.d/password-auth 2>/dev/null; then
    echo "Enabled"
else
    echo "Disabled"
fi