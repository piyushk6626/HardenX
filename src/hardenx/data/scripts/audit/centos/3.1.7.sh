#!/bin/bash

if rpm -q openldap-servers &>/dev/null; then
    echo "Installed"
else
    echo "Not Installed"
fi