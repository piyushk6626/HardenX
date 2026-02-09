#!/bin/bash

if dpkg-query -l xinetd &>/dev/null; then
    echo "Installed"
else
    echo "Not Installed"
fi