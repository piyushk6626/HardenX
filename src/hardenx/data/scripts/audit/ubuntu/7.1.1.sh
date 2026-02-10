#!/bin/bash

awk '/^PASS_MAX_DAYS/ {print $2}' /etc/login.defs