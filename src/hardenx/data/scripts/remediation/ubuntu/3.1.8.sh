#!/usr/bin/env bash

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
   echo "Error: This script must be run as root." >&2
   exit 1
fi

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 [Disabled|Not Installed]" >&2
    exit 1
fi

ACTION="$1"

case "$ACTION" in
    Disabled)
        services=("dovecot.service" "cyrus-imapd.service")
        for service in "${services[@]}"; do
            # Check if the service unit file exists before trying to manage it
            if systemctl list-unit-files --type=service | grep -q "^${service}"; then
                # --now flag stops the service in addition to disabling it
                systemctl --now disable "$service"
            fi
        done
        ;;

    'Not Installed')
        if command -v apt-get &>/dev/null; then
            apt-get purge -y 'dovecot-*' 'cyrus-*'
        elif command -v dnf &>/dev/null; then
            dnf remove -y 'dovecot-*' 'cyrus-*'
        elif command -v yum &>/dev/null; then
            yum remove -y 'dovecot-*' 'cyrus-*'
        else
            echo "Error: Unsupported package manager." >&2
            exit 1
        fi
        ;;

    *)
        echo "Error: Invalid argument. Use 'Disabled' or 'Not Installed'." >&2
        exit 1
        ;;
esac

true