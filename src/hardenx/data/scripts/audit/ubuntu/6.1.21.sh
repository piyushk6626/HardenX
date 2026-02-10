#!/usr/bin/env bash

sshd -T 2>/dev/null | grep -i '^permituserenvironment ' | awk '{print $2}'