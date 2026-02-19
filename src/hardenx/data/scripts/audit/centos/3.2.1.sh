#!/bin/bash

if rpm -q ypbind &>/dev/null; then
    echo "installed"
else
    echo "not installed"
fi