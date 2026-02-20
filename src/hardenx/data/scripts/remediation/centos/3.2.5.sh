#!/bin/bash

if [[ "$1" == "not installed" ]]; then
    if yum remove -y openldap-clients &>/dev/null; then
        echo "true"
    else
        echo "false"
    fi
fi