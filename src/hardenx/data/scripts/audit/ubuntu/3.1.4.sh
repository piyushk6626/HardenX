#!/bin/bash

if dpkg -s bind9 &> /dev/null || dpkg -s dnsmasq &> /dev/null; then
    echo "Installed"
else
    echo "Not Installed"
fi