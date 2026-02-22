#!/usr/bin/env bash

if [[ $# -ne 0 ]]; then
    echo "Error: This script does not accept any arguments." >&2
    false
elif [[ $EUID -ne 0 ]]; then
    echo "Error: This script must be run as root." >&2
    false
elif gpasswd -M "" shadow &> /dev/null; then
    true
else
    echo "Error: Failed to modify the 'shadow' group." >&2
    false
fi