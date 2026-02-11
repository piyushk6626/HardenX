#!/bin/bash

awk -F= '
/^INACTIVE=/ {
    val = $2
}
END {
    if (val > 0 && val == int(val)) {
        print val
    } else {
        print -1
    }
}' /etc/default/useradd