#!/bin/bash

if [[ "$#" -ne 1 || "$1" != "Not Installed" ]]; then
    echo "false"
    exit 1
fi

if DEBIAN_FRONTEND=noninteractive apt-get purge -y nis &>/dev/null; then
    echo "true"
else
    echo "false"
fi