#!/bin/bash

if rpm -q logrotate &>/dev/null; then
    echo "Installed"
else
    echo "Not Installed"
fi