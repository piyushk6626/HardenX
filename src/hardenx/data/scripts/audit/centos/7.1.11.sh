#!/usr/bin/env bash

root_path=$(sudo -i printenv PATH 2>/dev/null)
if [[ $? -ne 0 || -z "$root_path" ]]; then
    echo "Insecure"
    exit 0
fi

original_ifs=$IFS
IFS=':'

for dir in $root_path; do
    # An empty directory in PATH (e.g., /usr/bin::/bin) implies '.'
    if [[ -z "$dir" ]]; then
        dir="."
    fi

    # Check if the entry is the current directory '.'
    if [[ "$dir" == "." ]]; then
        echo "Insecure"
        IFS=$original_ifs
        exit 0
    fi

    # Check if the directory exists and is group or world-writable
    if [[ -d "$dir" && ( -g w "$dir" || -o w "$dir" ) ]]; then
        echo "Insecure"
        IFS=$original_ifs
        exit 0
    fi
done

IFS=$original_ifs
echo "Secure"