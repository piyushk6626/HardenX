#!/usr/bin/env bash

if pam-auth-update --display | grep -q '\[\*\] Unix authentication'; then
    echo "enabled"
else
    echo "disabled"
fi