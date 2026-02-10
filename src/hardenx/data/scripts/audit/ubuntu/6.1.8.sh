#!/usr/bin/env bash

sshd -T | grep -iw '^disableforwarding' | awk '{print $2}'