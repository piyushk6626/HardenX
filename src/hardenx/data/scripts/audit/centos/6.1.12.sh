#!/usr/bin/env bash

kex_algos=$(sshd -T | grep -i '^kexalgorithms' | awk '{print $2}')

if [[ -n "$kex_algos" ]]; then
    printf "Configured SSH Key Exchange algorithms: %s\n" "$kex_algos"
else
    printf "Could not determine SSH KexAlgorithms setting.\n"
fi