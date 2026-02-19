#!/usr/bin/env bash

if authconfig --test | grep -q 'pam_faillock'; then
    echo "Enabled"
else
    echo "Disabled"
fi