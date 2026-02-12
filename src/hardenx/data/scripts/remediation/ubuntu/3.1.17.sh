#!/usr/bin/env bash

if [[ "$1" == "Not Installed" ]]; then
    if dpkg-query -W -f='${Status}' squid 2>/dev/null | grep -q "install ok installed"; then
        if apt-get purge -y squid &>/dev/null; then
            echo "true"
        else
            echo "false"
        fi
    else
        echo "true"
    fi
fi