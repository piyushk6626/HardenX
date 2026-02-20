#!/usr/bin/env bash

if [[ $# -ne 1 ]]; then
    false
    exit 1
fi

STATE="$1"

case "$STATE" in
    "Disabled")
        if systemctl stop ufw && systemctl disable ufw; then
            true
        else
            false
        fi
        ;;
    "Not Installed")
        PKG_MANAGER=""
        if command -v dnf &>/dev/null; then
            PKG_MANAGER="dnf"
        elif command -v yum &>/dev/null; then
            PKG_MANAGER="yum"
        fi

        if [[ -n "$PKG_MANAGER" ]]; then
            if "$PKG_MANAGER" remove -y ufw; then
                true
            else
                false
            fi
        else
            false
        fi
        ;;
    *)
        false
        ;;
esac