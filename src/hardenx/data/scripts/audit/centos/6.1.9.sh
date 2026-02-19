#!/usr/bin/env bash

gssapi=$(sshd -T | grep -i '^gssapiauthentication' | awk '{print $2}')

if [[ -n "$gssapi" ]]; then
    printf "GSSAPIAuthentication is set to: %s\n" "$gssapi"
else
    printf "no"
fi