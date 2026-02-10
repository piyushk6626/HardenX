#!/usr/bin/env bash

sshd -T | grep -i '^gssapiauthentication' | awk '{print $2}'