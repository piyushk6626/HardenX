#!/usr/bin/env bash

default_out=$(ufw status verbose | grep '^Default:' | tr ',' '\n' | grep '(outgoing)' | awk '{print $1}')

if [[ -n "$default_out" ]]; then
    printf "UFW default outgoing policy: %s\n" "$default_ouet"
else
    printf "Could not determine UFW default outgoing policy.\n"
fi