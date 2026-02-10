#!/usr/bin/env bash

sshd -T | grep "^macs " | cut -d' ' -f2