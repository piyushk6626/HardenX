#!/usr/bin/env bash

awk '
    /^\s*\[defaults\]\s*$/ { in_section=1; next }
    /^\s*\[/ { in_section=0 }
    in_section && /^\s*crypt_style\s*=/ {
        sub(/^.*=[ \t]*/, "")
        sub(/[ \t]*#.*$/, "")
        sub(/[ \t]*$/, "")
        print
        exit
    }
' /etc/libuser.conf