#!/usr/bin/env bash

if (( EUID != 0 )); then
  echo "false"
  exit 1
fi

SUCCESS=true
CURRENT_DAYS=$(( $(date +%s) / 86400 ))

while IFS=: read -r username _ last_change _ ; do
  if [[ -z "$last_change" || ! "$last_change" =~ ^[0-9]+$ ]]; then
    continue
  fi

  if (( last_change > CURRENT_DAYS )); then
    uid=$(id -u "$username" 2>/dev/null)
    if [[ $? -eq 0 && -n "$uid" && "$uid" -ge 1000 ]]; then
      chage -d today "$username" &>/dev/null
      if [[ $? -ne 0 ]]; then
        SUCCESS=false
      fi
    fi
  fi
done < <(getent shadow)

echo "$SUCCESS"
exit 0