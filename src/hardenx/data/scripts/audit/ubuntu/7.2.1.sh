#!/bin/bash

if grep -Fxq -e '/usr/sbin/nologin' -e '/sbin/nologin' /etc/shells; then
    echo "Listed"
else
    echo "Not Listed"
fi