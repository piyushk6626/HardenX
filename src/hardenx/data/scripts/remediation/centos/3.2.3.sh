#!/bin/bash

if [[ "$#" -ne 1 ]]; then
    echo "Error: Exactly one argument ('Installed' or 'Not Installed') is required." >&2
    exit 1
fi

DESIRED_STATE="$1"

if [[ "$DESIRED_STATE" != "Installed" && "$DESIRED_STATE" != "Not Installed" ]]; then
    echo "Error: Argument must be 'Installed' or 'Not Installed'." >&2
    exit 1
fi

if command -v dnf &>/dev/null; then
    PKG_MGR="dnf"
elif command -v yum &>/dev/null; then
    PKG_MGR="yum"
else
    echo "Error: Neither 'dnf' nor 'yum' package manager found." >&2
    exit 1
fi

is_installed() {
    rpm -q talk &>/dev/null
}

if [[ "$DESIRED_STATE" == "Not Installed" ]]; then
    if is_installed; then
        "$PKG_MGR" remove -y talk &>/dev/null
    fi
fi

if [[ "$DESIRED_STATE" == "Installed" ]]; then
    if is_installed; then
        echo "true"
    else
        echo "false"
    fi
elif [[ "$DESIRED_STATE" == "Not Installed" ]]; then
    if ! is_installed; then
        echo "true"
    else
        echo "false"
    fi
fi