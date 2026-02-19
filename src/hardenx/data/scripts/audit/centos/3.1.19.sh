#!/bin/bash

if rpm -q xinetd &>/dev/null; then
    echo "installed"
else
    echo "not installed"
fi