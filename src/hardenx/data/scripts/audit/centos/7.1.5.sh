#!/bin/bash

INACTIVE_VALUE=$(grep --color=never '^INACTIVE=' /etc/default/useradd 2>/dev/null | cut -d'=' -f2)

if [[ -z "$INACTIVE_VALUE" || "$INACTIVE_VALUE" -lt 1 ]]; then
  echo "0"
else
  echo "$INACTIVE_VALUE"
fi