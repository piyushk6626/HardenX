#!/usr/bin/env bash

# This script must be run with sufficient privileges to read sudoers files.
if [[ $EUID -ne 0 ]] && ! [ -r "/etc/sudoers" ]; then
    # Attempt to use sudo if not root and can't read the file
    if command -v sudo >/dev/null && sudo -n true 2>/dev/null; then
        exec sudo "$0" "$@"
    fi
fi

# Concatenate the main sudoers file and all files in sudoers.d in order.
# The shell glob will expand files in lexicographical order, which is how sudo processes them.
# The pipeline does the following:
# 1. sed: Removes comments (from '#' to end of line) and then deletes any empty/whitespace-only lines.
# 2. grep: Finds all lines that are 'Defaults' directives and contain the word 'use_pty'.
# 3. tail: Gets the very last matching line, which is the setting that takes precedence.
last_setting=$(cat /etc/sudoers /etc/sudoers.d/* 2>/dev/null | \
    sed -e 's/#.*//' -e '/^\s*$/d' | \
    grep '^\s*Defaults.*\buse_pty\b' | \
    tail -n 1)

# Check the final effective setting.
if [ -z "$last_setting" ]; then
    # If no line was found, it's not actively configured.
    echo "false"
elif [[ "$last_setting" == *"!use_pty"* ]]; then
    # If the last setting includes negation (!use_pty), it's disabled.
    echo "false"
else
    # Otherwise, it is enabled.
    echo "true"
fi