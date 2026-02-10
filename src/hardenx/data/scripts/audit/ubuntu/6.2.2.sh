#!/usr/bin/env bash

# Concatenate all sudo configuration files, suppressing errors for non-existent files/dirs.
# Filter out comments, then find all lines setting 'use_pty'.
# The last matching line determines the effective configuration.
last_setting=$(cat /etc/sudoers /etc/sudoers.d/* 2>/dev/null | grep -v '^\s*#' | grep 'Defaults.*\buse_pty\b' | tail -n 1)

# Check if a setting was found and if it's negated.
if [[ -n "$last_setting" && "$last_setting" != *"!use_pty"* ]]; then
    echo "enabled"
else
    echo "disabled"
fi