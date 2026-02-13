#!/usr/bin/env bash

if [[ $# -ne 1 ]]; then
    false
    exit 1
fi

case "$1" in
    Enabled)
        pam-auth-update --force --enable pwquality
        ;;
    Disabled)
        pam-auth-update --force --disable pwquality
        ;;
    *)
        false
        ;;
esac