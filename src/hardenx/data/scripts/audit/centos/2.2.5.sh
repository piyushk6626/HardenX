#!/bin/bash

if systemctl is-enabled abrtd &>/dev/null; then
    echo "enabled"
else
    echo "disabled"
fi