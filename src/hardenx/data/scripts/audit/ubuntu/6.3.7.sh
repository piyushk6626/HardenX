#!/usr/bin/env bash

if pam-auth-update --display 2>/dev/null | grep -q '\[\*\] Password history management'; then
    echo "Enabled"
else
    echo "Disabled"
fi