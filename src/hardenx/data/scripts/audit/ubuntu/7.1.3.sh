#!/usr/bin/env bash

grep '^\s*PASS_WARN_AGE' /etc/login.defs | awk '{print $2}'