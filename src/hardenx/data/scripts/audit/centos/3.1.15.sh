#!/bin/bash

if rpm -q net-snmp &>/dev/null; then
    echo "Installed"
else
    echo "Not Installed"
fi