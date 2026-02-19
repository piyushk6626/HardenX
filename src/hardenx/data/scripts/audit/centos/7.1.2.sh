#!/bin/bash
grep '^PASS_MIN_DAYS' /etc/login.defs | awk '{print $2}'