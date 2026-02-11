#!/bin/bash

if auditctl -l | grep -q -- '-w /usr/sbin/usermod -p wa'; then
    echo "present"
else
    echo "absent"
fi