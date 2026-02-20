#!/bin/bash

DESIRED_STATE="$1"

if [[ "$DESIRED_STATE" != "Not Installed" ]]; then
    echo "false"
    exit 1
fi

# Check if the package is already uninstalled. If so, it's the desired state.
if ! rpm -q telnet &> /dev/null; then
    echo "true"
    exit 0
fi

# The package is installed, so we need to remove it.
# Determine which package manager to use.
if command -v dnf &> /dev/null; then
    PKG_MANAGER="dnf"
elif command -v yum &> /dev/null; then
    PKG_MANAGER="yum"
else
    # No supported package manager found to perform the action.
    echo "false"
    exit 1
fi

# Attempt to remove the package.
if "$PKG_MANAGER" remove -y telnet &> /dev/null; then
    echo "true"
    exit 0
else
    # The removal command failed.
    echo "false"
    exit 1
fi