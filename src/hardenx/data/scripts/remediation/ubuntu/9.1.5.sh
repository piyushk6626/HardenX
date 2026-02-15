#!/bin/bash

if chmod "$1" /etc/shadow &>/dev/null; then
  echo "true"
else
  echo "false"
fi