#!/usr/bin/env bash

if grep -s -r -E '^\s*auth\s+.*\s+pam_faillock\.so\s+.*\s+even_deny_root' /etc/pam.d/ > /dev/null 2>&1; then
  echo "true"
else
  echo "false"
fi