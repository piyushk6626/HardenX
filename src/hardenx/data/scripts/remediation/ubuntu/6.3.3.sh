#!/bin/bash

if [[ $# -ne 1 ]] || [[ "$1" != "Installed" ]]; then
    echo "false"
    exit 1
fi

if dpkg-query -W -f='${Status}' libpam-pwquality 2>/dev/null | grep -q "ok installed"; then
    echo "true"
    exit 0
fi

if apt-get install -y libpam-pwquality &>/dev/null; then
    echo "true"
    exit 0
else
    echo "false"
    exit 1
fi