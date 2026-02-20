#!/usr/bin/env bash

if [ "$EUID" -ne 0 ]; then
  echo "false"
  exit 1
fi

if [ "$#" -ne 1 ] || [ "$1" != "enforce" ]; then
  echo "false"
  exit 1
fi

if ufw default deny incoming &>/dev/null && \
   ufw default allow outgoing &>/dev/null && \
   ufw --force enable &>/dev/null && \
   ufw reload &>/dev/null; then
  echo "true"
  exit 0
else
  echo "false"
  exit 1
fi