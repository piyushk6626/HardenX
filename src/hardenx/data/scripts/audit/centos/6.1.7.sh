#!/usr/bin/env bash

awk '
    /^[[:space:]]*ClientAliveInterval[[:space:]]+/ { interval = $2 }
    /^[[:space:]]*ClientAliveCountMax[[:space:]]+/ { countmax = $2 }
END {
    if (interval == "") interval = 0;
    if (countmax == "") countmax = 3;
    print interval ":" countmax;
}' /etc/ssh/sshd_config