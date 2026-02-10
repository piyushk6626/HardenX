#!/usr/bin/env bash

val_all=$(sysctl -n net.ipv4.conf.all.send_redirects 2>/dev/null)
val_default=$(sysctl -n net.ipv4.conf.default.send_redirects 2>/dev/null)

if [[ "$val_all" == "0" && "$val_default" == "0" ]]; then
    echo "0"
else
    echo "1"
fi