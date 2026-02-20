#!/bin/bash

if [[ $# -ne 1 ]]; then
    false
    exit 1
fi

DESIRED_STATE="$1"

case "$DESIRED_STATE" in
    'Not Installed')
        if command -v dnf &>/dev/null; then
            if dnf remove -y vsftpd &>/dev/null; then
                true
            else
                false
            fi
        elif command -v yum &>/dev/null; then
            if yum remove -y vsftpd &>/dev/null; then
                true
            else
                false
            fi
        else
            false
        fi
        ;;
    'disabled')
        if systemctl disable --now vsftpd &>/dev/null; then
            true
        else
            false
        fi
        ;;
    *)
        false
        ;;
esac
