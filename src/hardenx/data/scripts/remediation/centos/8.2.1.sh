#!/usr/bin/env bash

if [[ $# -ne 1 ]] || [[ "$1" != "installed" ]]; then
    echo "false"
    exit 0
fi

PKG_MANAGER=""
if command -v dnf &>/dev/null; then
    PKG_MANAGER="dnf"
elif command -v yum &>/dev/null; then
    PKG_MANAGER="yum"
else
    echo "false"
    exit 0
fi

if sudo "${PKG_MANAGER}" install -y audit audit-libs &>/dev/null; then
    echo "true"
else
    echo "false"
fi