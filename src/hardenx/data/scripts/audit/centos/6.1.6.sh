#!/usr/bin/env bash

awk '
    tolower($1) == "ciphers" {
        $1 = ""
        sub(/^[[:space:]]+/, "")
        value = $0
    }
    END {
        print value
    }
' /etc/ssh/sshd_config