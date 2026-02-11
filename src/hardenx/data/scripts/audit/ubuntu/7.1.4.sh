#!/usr/bin/env bash

# Find the line with ENCRYPT_METHOD, ignore comments, and print the second field.
grep -E '^\s*ENCRYPT_METHOD' /etc/login.defs | awk '{print $2}'