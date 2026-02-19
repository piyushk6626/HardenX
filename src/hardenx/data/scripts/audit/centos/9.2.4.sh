#!/bin/bash
#9.2.4

members=$(awk -F: '/^shadow:/ {print $4}' /etc/group)

if [ -n "$members" ]; then
    echo " Non-compliant: The 'shadow' group has members:"
    echo "   $members"
else
    echo "[]"
fi