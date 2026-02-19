#!/bin/bash

remember_value=$(grep -Pho -- '^\s*password\s+.*\s+pam_pwhistory.so\s+.*remember=\K[0-9]+' /etc/pam.d/system-auth /etc/pam.d/password-auth 2>/dev/null | head -n 1)

echo "${remember_value:-0}"
