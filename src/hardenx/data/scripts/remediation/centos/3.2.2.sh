#!/bin/bash

if [[ "$1" != "Not Installed" ]]; then
    exit 0
fi

if ! rpm -q rsh &>/dev/null; then
    echo "true"
    exit 0
fi

if yum remove -y rsh &>/dev/null; then
    echo "true"
else
    echo "false"
fi