#!/bin/bash

all_dirs_exist=true

while IFS= read -r home_dir; do
    if [ ! -d "$home_dir" ]; then
        all_dirs_exist=false
        break
    fi
done < <(awk -F: '$3 >= 1000 && $7 != "/sbin/nologin" && $7 != "/bin/false" {print $6}' /etc/passwd)

echo "$all_dirs_exist"