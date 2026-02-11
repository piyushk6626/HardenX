#!/usr/bin/env bash

awk '/^[[:space:]]*UMASK[[:space:]]/ {print $2}' /etc/login.defs