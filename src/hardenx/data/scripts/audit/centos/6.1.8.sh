#!/usr/bin/env bash

if [ -f /etc/ssh/sshd_config ] && grep -q -E '^\s*DisableForwarding\s+yes\s*$' /etc/ssh/sshd_config; then
    echo "yes"
else
    echo "no"
fi