#!/bin/bash

if authconfig --test 2>&1 | grep -q "pam_pwhistory.so"; then
    echo "Enabled"
else
    echo "Disabled"
fi