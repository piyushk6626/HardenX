#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "false"
   exit 1
fi

if [[ $# -ne 1 ]]; then
    echo "false"
    exit 1
fi

ACTION="$1"

case "$ACTION" in
    "Enabled")
        if apt-get update -y &>/dev/null && apt-get install -y rsyslog &>/dev/null && systemctl enable --now rsyslog &>/dev/null; then
            echo "true"
        else
            echo "false"
        fi
        ;;
    "Disabled")
        if systemctl disable --now rsyslog &>/dev/null; then
            echo "true"
        else
            # This case handles when the service file doesn't exist (package not installed)
            # which we'll treat as a failure to perform the "disable" action.
            echo "false"
        fi
        ;;
    "Not Installed")
        # Check if the package is installed before attempting to purge
        if dpkg-query -W -f='${Status}' rsyslog 2>/dev/null | grep -q "ok installed"; then
            if apt-get purge -y rsyslog &>/dev/null; then
                echo "true"
            else
                echo "false"
            fi
        else
            # If the package is already not installed, the desired state is met.
            echo "true"
        fi
        ;;
    *)
        echo "false"
        ;;
esac