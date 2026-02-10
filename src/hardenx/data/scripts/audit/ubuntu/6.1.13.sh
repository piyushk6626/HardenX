#!/usr/bin/env bash

sshd -T | grep -i '^logingracetime ' | awk '{print $2}'