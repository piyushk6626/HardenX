#!/bin/bash

if [ -f "/etc/cron.allow" ]; then
    echo 'Allow Configured'
elif [ -f "/etc/cron.deny" ]; then
    echo 'Deny Configured'
else
    echo 'Unrestricted'
fi