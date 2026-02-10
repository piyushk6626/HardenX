#!/usr/bin/env bash

val1=$(sysctl -n net.ipv4.conf.all.accept_source_route 2>/dev/null)
val2=$(sysctl -n net.ipv4.conf.default.accept_source_route 2>/dev/null)

if [ "$val1" = "0" ] && [ "$val2" = "0" ]; then
  echo "0"
else
  echo "1"
fi