#!/usr/bin/env bash

val1=$(sysctl -n net.ipv6.conf.all.accept_ra)
val2=$(sysctl -n net.ipv6.conf.default.accept_ra)

echo "${val1},${val2}"