#!/usr/bin/env bash

if [[ "$1" == "Configured" ]] && ufw allow in on lo &>/dev/null && ufw allow out on lo &>/dev/null; then
  echo "true"
else
  echo "false"
fi