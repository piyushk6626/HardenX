#!/bin/bash

if [[ -f "/etc/issue" ]]; then
    cat "/etc/issue"
else
    echo -n ""
fi