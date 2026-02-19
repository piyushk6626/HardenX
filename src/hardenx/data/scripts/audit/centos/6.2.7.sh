#!/bin/bash

if grep -q -E '^[[:space:]]*auth[[:space:]]+required[[:space:]]+pam_wheel.so[[:space:]]+use_uid' /etc/pam.d/su; then
    echo "Enabled"
else
    echo "Disabled"
fi