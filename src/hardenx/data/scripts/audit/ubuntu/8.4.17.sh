#!/bin/bash

if auditctl -l 2>/dev/null | grep -E -- '-w /usr/bin/chacl\b' | grep -q -- '-p.*x'; then
    echo 'present'
else
    echo 'absent'
fi