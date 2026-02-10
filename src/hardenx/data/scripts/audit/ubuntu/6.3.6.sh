#!/bin/bash

if pam-auth-update --display | grep -q '^\[\*\] Password quality checking'; then
    echo "Enabled"
else
    echo "Disabled"
fi