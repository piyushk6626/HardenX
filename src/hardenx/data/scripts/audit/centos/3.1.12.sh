#!/bin/bash

if ! systemctl list-unit-files --full --all | grep -q '^rpcbind\.service'; then
    echo "not installed"
else
    systemctl is-enabled rpcbind
fi