#!/bin/bash

if dpkg-query -l aide &>/dev/null; then
    echo "Installed"
else
    echo "Not Installed"
fi