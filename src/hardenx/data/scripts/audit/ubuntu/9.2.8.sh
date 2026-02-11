#!/usr/bin/env bash

output=$(cut -d: -f1 /etc/group | sort | uniq -d)
echo -n $output