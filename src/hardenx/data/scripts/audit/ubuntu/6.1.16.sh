#!/usr/bin/env bash

sshd -T 2>/dev/null | grep -i '^maxauthtries' | awk '{print $2}'