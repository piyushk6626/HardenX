#!/usr/bin/env bash

mount_options=$(findmnt --noheadings --output OPTIONS /var/log 2>/dev/null)
exit_code=$?

if [ "$exit_code" -ne 0 ]; then
    echo "Disabled"
    exit 0
fi

if [[ ",$mount_options," == *",noexec,"* ]]; then
    echo "Enabled"
else
    echo "Disabled"
fi