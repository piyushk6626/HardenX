#!/usr/bin/env bash
sshd -T | grep -i '^usepam' | awk '{print $2}'