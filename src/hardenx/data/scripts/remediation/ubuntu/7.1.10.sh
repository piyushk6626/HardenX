#!/usr/bin/env bash

if [[ "$#" -ne 1 ]]; then
    false
    exit $?
fi

case "$1" in
    Locked)
        passwd -l root
        ;;
    Unlocked)
        passwd -u root
        ;;
    *)
        false
        ;;
esac