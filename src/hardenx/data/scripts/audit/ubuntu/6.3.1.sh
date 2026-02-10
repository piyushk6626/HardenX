#!/bin/bash

apt-get update -qq >/dev/null 2>&1

if apt list --upgradable 2>/dev/null | grep -q '^libpam-runtime/'; then
    echo "update-available"
else
    echo "up-to-date"
fi