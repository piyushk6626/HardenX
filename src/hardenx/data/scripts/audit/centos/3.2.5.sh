#!/bin/bash

if (command -v rpm &>/dev/null && rpm -q openldap-clients &>/dev/null) || \
   (command -v dpkg &>/dev/null && dpkg -s openldap-clients &>/dev/null); then
    echo "installed"
else
    echo "not installed"
fi