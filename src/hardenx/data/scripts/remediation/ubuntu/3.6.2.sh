#!/bin/bash

if chmod "$1" /etc/crontab &> /dev/null; then
    true
else
    false
fi