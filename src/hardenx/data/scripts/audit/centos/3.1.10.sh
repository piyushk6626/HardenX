#!/bin/bash

if rpm -q ypserv &>/dev/null; then
    echo "Installed"
else
    echo "Not Installed"
fi