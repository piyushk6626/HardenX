#!/bin/bash

if auditctl -l | grep -q -- '-w /var/log/sudo.log -p wa'; then
    echo "present"
else
    echo "absent"
fi