#!/bin/bash

desired_state="$1"

if [[ "$desired_state" != "not installed" ]]; then
    echo "false"
    exit 0
fi

is_installed() {
    rpm -q ypbind &>/dev/null
}

if is_installed; then
    pkg_manager=""
    if command -v dnf &>/dev/null; then
        pkg_manager="dnf"
    elif command -v yum &>/dev/null; then
        pkg_manager="yum"
    else
        # Cannot remove, so final state will not match desired state
        echo "false"
        exit 0
    fi
    
    "$pkg_manager" remove -y ypbind &>/dev/null
fi

# Verify final state
if ! is_installed; then
    echo "true"
else
    echo "false"
fi