#!/usr/bin/env bash

dpkg -s nfs-kernel-server &>/dev/null
nfs_installed=$?

dpkg -s rpcbind &>/dev/null
rpcbind_installed=$?

if [[ $nfs_installed -ne 0 && $rpcbind_installed -ne 0 ]]; then
    echo "Not Installed"
    exit 0
fi

nfs_enabled=1
if [[ $nfs_installed -eq 0 ]]; then
    systemctl is-enabled nfs-kernel-server &>/dev/null
    nfs_enabled=$?
fi

rpcbind_enabled=1
if [[ $rpcbind_installed -eq 0 ]]; then
    systemctl is-enabled rpcbind &>/dev/null
    rpcbind_enabled=$?
fi

if [[ $nfs_enabled -eq 0 || $rpcbind_enabled -eq 0 ]]; then
    echo "Enabled"
else
    echo "Disabled"
fi