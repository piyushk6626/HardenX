#!/bin/bash

awk '$1 == "Ciphers" { $1=""; sub(/^[ \t]+/, ""); print }' /etc/ssh/sshd_config