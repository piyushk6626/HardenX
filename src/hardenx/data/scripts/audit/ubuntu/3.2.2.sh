#!/bin/bash

if dpkg-query -l rsh-client &> /dev/null; then
    echo "Installed"
else
    echo "Not Installed"
fi