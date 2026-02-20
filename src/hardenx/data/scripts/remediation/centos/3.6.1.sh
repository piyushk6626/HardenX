#!/usr/bin/env bash

if [[ "$1" == "enabled-active" ]] && systemctl enable --now crond &>/dev/null; then
  echo "true"
else
  echo "false"
fi