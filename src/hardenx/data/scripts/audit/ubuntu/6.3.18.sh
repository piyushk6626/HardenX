#!/bin/bash

value=$(grep -oE 'remember=[0-9]+' /etc/pam.d/common-password 2>/dev/null | cut -d'=' -f2)

echo "${value:-0}"