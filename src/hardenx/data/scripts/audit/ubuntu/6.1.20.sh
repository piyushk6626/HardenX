#!/usr/bin/env bash

sshd -T 2>/dev/null | grep -i '^permitrootlogin' | awk '{print $2}'