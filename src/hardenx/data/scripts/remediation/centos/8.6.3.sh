#!/usr/bin/env bash

set -eo pipefail

fail() {
    echo "false"
    exit 1
}

if [[ $EUID -ne 0 ]]; then
   fail
fi

if [[ "$1" != "install" ]]; then
    fail
fi

if command -v dnf &>/dev/null; then
    PKG_MANAGER="dnf"
elif command -v yum &>/dev/null; then
    PKG_MANAGER="yum"
else
    fail
fi

# Redirect stdout and stderr to /dev/null to ensure only true/false is printed
{
    $PKG_MANAGER install -y aide
    aide --init
    if [[ -f /var/lib/aide/aide.db.new.gz ]]; then
        mv /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz
    else
        # aide --init failed to create the database file
        fail
    fi
} &>/dev/null || fail

echo "true"
exit 0