#!/bin/bash

grep -E '^(server|pool)\s+' /etc/chrony.conf 2>/dev/null | awk '{print $2}' | paste -sd,