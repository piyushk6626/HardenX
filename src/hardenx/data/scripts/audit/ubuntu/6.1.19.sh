#!/usr/bin/env bash

sshd -T | grep -i '^permitemptypasswords' | awk '{print $2}'