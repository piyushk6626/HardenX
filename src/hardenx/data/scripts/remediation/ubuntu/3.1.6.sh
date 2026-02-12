#!/bin/bash

if [[ "$1" != "Not Installed" ]]; then
    echo "false"
    exit 1
fi

declare -a ftp_packages=("vsftpd" "proftpd-basic" "pure-ftpd")
declare -a packages_to_remove=()

for pkg in "${ftp_packages[@]}"; do
    if dpkg -s "$pkg" &> /dev/null; then
        packages_to_remove+=("$pkg")
    fi
done

if [ ${#packages_to_remove[@]} -eq 0 ]; then
    echo "true"
    exit 0
fi

if apt-get purge -y "${packages_to_remove[@]}" &> /dev/null; then
    echo "true"
else
    echo "false"
fi