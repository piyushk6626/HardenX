#!/usr/bin/env bash

if [[ "$EUID" -ne 0 ]]; then
  echo "false"
  exit 1
fi

if [[ $# -ne 1 ]]; then
  echo "false"
  exit 1
fi

if echo "$1" > /etc/issue; then
  echo "true"
else
  echo "false"
fi