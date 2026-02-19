#!/usr/bin/env bash

if (modprobe --showconfig | grep -Pq '^\s*install\s+sctp\s+/bin/(true|false)') && ! (lsmod | grep -q '^sctp\s'); then
  echo "Not Available"
else
  echo "Available"
fi