#!/bin/bash

if [[ "$#" -ne 1 || "$1" != "Not Installed" ]]; then
    echo "false"
    exit 1
fi

if yum remove -y openldap-servers &>/dev/null; then
    echo "true"
else
    echo "false"
fi