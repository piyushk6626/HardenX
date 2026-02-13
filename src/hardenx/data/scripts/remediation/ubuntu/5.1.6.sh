#!/usr/bin/env bash

# This script is intended to be run with root privileges.

main() {
    if [[ "$1" != "enabled" ]]; then
        echo "false"
        return 1
    fi

    # Ensure UFW is installed
    if ! command -v ufw &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            apt-get update -qq && apt-get install -y -qq ufw
        elif command -v dnf &> /dev/null; then
            dnf install -y -q ufw
        elif command -v yum &> /dev/null; then
            yum install -y -q ufw
        else
            echo "false"
            return 1
        fi

        if ! command -v ufw &> /dev/null; then
            echo "false"
            return 1
        fi
    fi

    # Configure and enable UFW, exit on any failure
    {
        ufw default deny incoming
        ufw default allow outgoing
        echo "y" | ufw enable
    } &> /dev/null

    # Verify UFW is active
    if ufw status | grep -q "Status: active"; then
        echo "true"
        return 0
    else
        echo "false"
        return 1
    fi
}

if [[ $EUID -ne 0 ]]; then
   echo "false"
   exit 1
fi

main "$@"