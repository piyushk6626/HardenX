#!/bin/bash

if [[ $# -ne 1 ]]; then
    echo "false"
    exit 1
fi

DESIRED_STATE="$1"

if [[ "${DESIRED_STATE}" == "Disabled" ]]; then
    # Unload the module if it is currently loaded.
    if lsmod | grep -q '^tipc '; then
        if ! rmmod tipc; then
            echo "false"
            exit 1
        fi
    fi

    # Create a modprobe configuration to prevent the module from loading.
    if ! echo "install tipc /bin/true" > /etc/modprobe.d/tipc.conf; then
        echo "false"
        exit 1
    fi

    echo "true"
else
    # If the desired state is not 'Disabled', no action is required.
    # Consider this a success as per the request's scope.
    echo "true"
fi