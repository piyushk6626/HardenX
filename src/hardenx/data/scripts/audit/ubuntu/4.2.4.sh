#!/usr/bin/env bash

if ! lsmod | grep -q sctp && modprobe -n -v sctp | grep -q 'install /bin/true'; then
    echo 'disabled'
else
    echo 'enabled'
fi