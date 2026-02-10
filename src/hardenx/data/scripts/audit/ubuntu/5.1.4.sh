#!/usr/bin/env bash

ACTION=$(sudo ufw status verbose 2>/dev/null | grep ' on lo ' | grep -o -E 'ALLOW|DENY|REJECT' | head -n 1)

if [[ -n "$ACTION" ]]; then
  echo "$ACTION"
else
  echo "unconfigured"
fi