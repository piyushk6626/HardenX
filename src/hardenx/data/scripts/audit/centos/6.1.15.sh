#!/usr/bin/env bash

sshd -T 2>/dev/null | awk '/^macs / {print $2}'