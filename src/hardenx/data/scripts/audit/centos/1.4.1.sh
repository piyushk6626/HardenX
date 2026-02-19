#!/usr/bin/env bash

if [[ "$(stat -c %d /)" != "$(stat -c %d /home)" ]]; then
    echo "true"
else
    echo "false"
fi