#!/bin/bash

if [[ "$1" == "Installed" ]] && apt-get install -y logrotate &>/dev/null; then
    echo "true"
else
    echo "false"
fi