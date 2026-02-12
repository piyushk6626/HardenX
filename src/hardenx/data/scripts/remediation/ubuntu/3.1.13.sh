#!/bin/bash

if [[ "$#" -ne 1 ]]; then
    echo "false"
    exit 1
fi

DESIRED_STATE="$1"

if [[ "${DESIRED_STATE}" == "Not Installed" ]]; then
    # Perform the sequence of actions. We don't care about individual failures,
    # as the service or package might already be gone. The final check is what matters.
    # All output is redirected to /dev/null to keep the script's output clean.
    systemctl stop rsync &>/dev/null || true
    systemctl disable rsync &>/dev/null || true
    systemctl mask rsync &>/dev/null || true
    apt-get purge -y rsync &>/dev/null || true

    # Verify the final state. Success is defined as the package being absent.
    # dpkg -s returns 0 if the package is installed, non-zero otherwise.
    if ! dpkg -s rsync &>/dev/null; then
        echo "true"
    else
        echo "false"
    fi
else
    echo "false"
fi