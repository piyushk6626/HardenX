#!/bin/bash

awk '/^UMASK/ && !/^#/ {print $2}' /etc/login.defs