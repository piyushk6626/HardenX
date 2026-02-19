#!/bin/bash

if findmnt -n -o OPTIONS /var | grep -qw 'nosuid'; then
    echo 'nosuid'
else
    echo 'none'
fi