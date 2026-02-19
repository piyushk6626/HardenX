#!/bin/bash

NON_ROOT_OWNER=$(find /etc/audit/ \! -user root -printf '%u\n' -quit)

if [ -z "$NON_ROOT_OWNER" ]; then
    echo "root"
else
    echo "$NON_ROOT_OWNER"
fi