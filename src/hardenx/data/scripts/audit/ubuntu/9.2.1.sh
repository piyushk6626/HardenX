#!/usr/bin/env bash

if shadowconfig --status 2>/dev/null | grep -q " on$"; then
    echo "on"
else
    echo "off"
fi