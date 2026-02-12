#!/usr/bin/env bash

if [ "$#" -ne 1 ]; then
    echo "false"
    exit 1
fi

desired_state="$1"
package_name="isc-dhcp-server"

if [ "$desired_state" != "Not Installed" ]; then
    exit 0
fi

if ! dpkg-query -W -f='${Status}' "$package_name" 2>/dev/null | grep -q "install ok installed"; then
    echo "true"
    exit 0
fi

if apt-get purge -y "$package_name" &>/dev/null; then
    echo "true"
else
    echo "false"
fi