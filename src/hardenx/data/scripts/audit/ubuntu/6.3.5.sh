#!/bin/bash

if pam-auth-update --display | grep -q '\[\*\] Faillock failure locking'; then
    echo "Enabled"
else
    echo "Disabled"
fi