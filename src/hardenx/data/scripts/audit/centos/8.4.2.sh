#!/usr/bin/env bash

rules=$(auditctl -l 2>/dev/null)

if echo "$rules" | grep -q -- "arch=b64" | grep -q -- "setuid" && \
   echo "$rules" | grep -q -- "arch=b32" | grep -q -- "setuid" && \
   echo "$rules" | grep -q -- "arch=b64" | grep -q -- "setgid" && \
   echo "$rules" | grep -q -- "arch=b32" | grep -q -- "setgid"; then
    echo "true"
else
    echo "false"
fi