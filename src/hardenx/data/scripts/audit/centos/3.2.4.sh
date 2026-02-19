#!/bin/bash

if rpm -q telnet &>/dev/null; then
    echo "Installed"
else
    echo "Not Installed"
fi