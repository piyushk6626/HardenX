#!/usr/bin/env bash

if cat /etc/sudoers /etc/sudoers.d/* 2>/dev/null | grep -v -E '^\s*#' | grep -q 'NOPASSWD'; then
    echo "Disabled"
else
    echo "Enabled"
fi