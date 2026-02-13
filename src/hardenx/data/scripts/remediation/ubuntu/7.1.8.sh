#!/usr/bin/env bash

if [[ $# -ne 1 ]]; then
    echo "false"
    exit 1
fi

if [[ "$(id -u)" -ne 0 ]]; then
    echo "false"
    exit 1
fi

USERNAME="$1"

# Check if user exists
if ! id -u "${USERNAME}" &>/dev/null; then
    echo "false"
    exit 1
fi

# Check if the target group already exists
if getent group "${USERNAME}" &>/dev/null; then
    echo "false"
    exit 1
fi

# Create a new group with the same name as the user
if ! groupadd "${USERNAME}"; then
    echo "false"
    exit 1
fi

# Modify the user's primary group to the new group
if usermod -g "${USERNAME}" "${USERNAME}"; then
    echo "true"
else
    # Clean up the created group on failure
    groupdel "${USERNAME}" &>/dev/null
    echo "false"
    exit 1
fi