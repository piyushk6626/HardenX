#!/bin/bash

awk '/^PASS_MIN_DAYS/ {print $2}' /etc/login.defs