#!/bin/bash

if [ -s "/etc/issue.net" ]; then
    echo "Configured"
else
    echo "Not Configured"
fi