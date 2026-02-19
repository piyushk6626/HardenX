#!/usr/bin/env bash

val_all=$(sysctl -n net.ipv4.conf.all.rp_filter 2>/dev/null)
val_default=$(sysctl -n net.ipv4.conf.default.rp_filter 2>/dev/null)

if [ "$val_all" == "$val_default" ]; then
    echo "$val_all"
else
    echo "mismatch"
fi