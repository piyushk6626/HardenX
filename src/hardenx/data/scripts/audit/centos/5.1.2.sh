#!/bin/bash

if rpm -q ufw &>/dev/null && rpm -q iptables-services &>/dev/null; then
    echo "CONFLICT"
else
    echo "OK"
fi