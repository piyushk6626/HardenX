#!/bin/bash

if [[ "$EUID" -ne 0 ]]; then
  echo "false"
  exit 1
fi

if [[ "$#" -ne 1 ]]; then
  echo "false"
  exit 1
fi

new_umask="$1"

if ! [[ "$new_umask" =~ ^[0-7]{3,4}$ ]]; then
  echo "false"
  exit 1
fi

files_to_check=("/root/.profile" "/root/.bashrc")
profile_file="/root/.profile"
umask_found=false

umask_pattern='^[[:space:]]*umask[[:space:]]+[0-7]{3,4}'
correct_umask_pattern="^[[:space:]]*umask[[:space:]]+$new_umask"

for file in "${files_to_check[@]}"; do
  if [[ ! -f "$file" ]] || [[ ! -r "$file" ]] || [[ ! -w "$file" ]]; then
    continue
  fi

  if grep -qE "$umask_pattern" "$file"; then
    umask_found=true
    if ! grep -qE "$correct_umask_pattern" "$file"; then
      sed -i -E "s/^\s*umask\s+[0-7]{3,4}/umask $new_umask/" "$file"
      if [[ $? -ne 0 ]]; then
        echo "false"
        exit 1
      fi
    fi
  fi
done

if ! $umask_found; then
  if [[ ! -f "$profile_file" ]] || [[ ! -w "$profile_file" ]]; then
    echo "false"
    exit 1
  fi
  
  if [[ -n "$(tail -c 1 "$profile_file")" ]]; then
    echo "" >> "$profile_file"
    if [[ $? -ne 0 ]]; then echo "false"; exit 1; fi
  fi
  
  echo "umask $new_umask" >> "$profile_file"
  if [[ $? -ne 0 ]]; then
    echo "false"
    exit 1
  fi
fi

echo "true"
exit 0