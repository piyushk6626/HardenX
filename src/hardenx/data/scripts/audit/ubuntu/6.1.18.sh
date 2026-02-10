#!/usr/bin/env bash

sshd -T | grep '^maxstartups' | awk '{print $2}'