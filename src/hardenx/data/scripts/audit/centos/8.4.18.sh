#!/bin/bash

if auditctl -l 2>/dev/null | grep -E -- "-w /usr/sbin/usermod( |$)" | grep -E -- "-p wa( |$)" | grep -q -E -- "-k usermod( |$)"; then
    echo "Present"
else
    echo "Not Present"
fi