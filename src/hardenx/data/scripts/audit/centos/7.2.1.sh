#!/bin/bash

if grep -q -x -E '/sbin/nologin|/usr/sbin/nologin' /etc/shells; then
    echo "Listed"
else
    echo "Not Listed"
fi