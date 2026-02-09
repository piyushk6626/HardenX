#!/bin/bash

if dpkg -s isc-dhcp-server &>/dev/null; then
    echo "Installed"
else
    echo "Not Installed"
fi