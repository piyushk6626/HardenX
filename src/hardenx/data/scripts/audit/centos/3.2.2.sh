#!/bin/bash

if rpm -q rsh &>/dev/null; then
    echo "Installed"
else
    echo "Not Installed"
fi