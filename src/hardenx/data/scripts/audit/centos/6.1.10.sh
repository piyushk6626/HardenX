#!/usr/bin/env bash

hostbased=$(sshd -T | grep -i '^hostbasedauthentication ' | awk '{print $2}')

if [[ -n "$hostbased" ]]; then
    printf "HostBasedAuthentication is set to: %s\n" "$hostbased"
else
    printf "deny"
fi