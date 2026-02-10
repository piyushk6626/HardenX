#!/bin/bash

awk '/^[[:space:]]*LogLevel/ && !/^[[:space:]]*#/ {
    val=$2
}
END {
    if (val) {
        print val
    } else {
        print "INFO"
    }
}' /etc/ssh/sshd_config