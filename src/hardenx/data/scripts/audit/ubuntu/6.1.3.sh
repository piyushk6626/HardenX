#!/usr/bin/env bash

shopt -s nullglob
declare -a perms_array

for file in /etc/ssh/ssh_host_*.pub; do
  if [[ -f "$file" ]]; then
    perms_array+=("$(stat -c "%a" "$file")")
  fi
done

if (( ${#perms_array[@]} > 0 )); then
  (IFS=,; echo "${perms_array[*]}")
fi