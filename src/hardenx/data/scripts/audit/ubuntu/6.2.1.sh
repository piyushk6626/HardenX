#!/bin/bash

if dpkg -s sudo &> /dev/null; then
    echo "Installed"
else
    echo "Not Installed"
fi