#!/bin/bash

if grep -q -E '(^| )audit=1($| )' /proc/cmdline; then
    echo "enabled"
else
    echo "disabled"
fi