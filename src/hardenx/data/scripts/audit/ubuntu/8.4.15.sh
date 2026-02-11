#!/usr/bin/env bash

rules=$(auditctl -l 2>/dev/null)

if echo "$rules" | grep -q -- '-a always,exit -F path=/usr/bin/chcon -F perm=x -F auid>=1000 -F auid!=-1 -k perm_mod' && \
   echo "$rules" | grep -q -- '-a always,exit -F path=/usr/bin/chcon -F perm=x -F auid=0 -k perm_mod'; then
    echo "true"
else
    echo "false"
fi