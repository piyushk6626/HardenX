#!/bin/bash

if find /var/log -type f -perm /o+rwx -print -quit | grep -q '.*'; then
    echo "Non-Compliant"
else
    echo "Compliant"
fi