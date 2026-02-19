#!/bin/bash

if auditctl -l 2>/dev/null | grep -E -- "(-S|syscall=)execve" | grep -- "euid=0" | grep -- "auid>=1000" | grep -q "."; then
    echo "Present"
else
    echo "Not Present"
fi