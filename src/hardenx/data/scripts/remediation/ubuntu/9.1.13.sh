#!/bin/bash

if chmod u-s,g-s "$1" &>/dev/null; then
  echo "true"
else
  echo "false"
fi