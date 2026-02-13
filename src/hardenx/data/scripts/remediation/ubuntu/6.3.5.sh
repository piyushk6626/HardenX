#!/usr/bin/env bash

if [ "$#" -ne 1 ]; then
    false
    exit 1
fi

case "$1" in
    Enabled)
        if pam-auth-update --enable faillock --force; then
            true
        else
            false
        fi
        ;;
    Disabled)
        if pam-auth-update --disable faillock --force; then
            true
        else
            false
        fi
        ;;
    *)
        false
        ;;
esac