#!/usr/bin/env bash

set -euo pipefail

services=$(ss -ltunp 2>/dev/null | awk '
    /users:\(\("/ {
        split($5, addr, ":")
        port = addr[length(addr)]

        if (match($0, /users:\(\("([^"]+)"/)) {
            name = substr($0, RSTART + 9, RLENGTH - 10)
            if (name != "" && port != "") {
                print name ":" port
            }
        }
    }' | sort -u | paste -sd, -)

printf "%s" "$services"
printf "\n"