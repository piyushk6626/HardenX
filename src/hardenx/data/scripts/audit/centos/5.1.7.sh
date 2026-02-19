#!/usr/bin/env bash

default_in=$(ufw status verbose | grep 'Default:' | awk '{print $2}' | sed 's/[(),]//g')

if [[ -n "$default_in" ]]; then
    printf "UFW default incoming policy: %s\n" "$default_in"
else
    printf "deny"
fi