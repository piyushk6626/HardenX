#!/usr/bin/env bash

status_output=$(ufw status numbered 2>/dev/null)

if echo "$status_output" | grep -q "on lo.*ALLOW IN" && echo "$status_output" | grep -q "on lo.*ALLOW OUT"; then
    echo "Configured"
else
    echo "Not Configured"
fi