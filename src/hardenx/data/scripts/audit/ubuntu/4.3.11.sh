#!/usr/bin/env bash

#
# This script checks if IPv6 router advertisements are disabled.
# It exits with 0 if both net.ipv6.conf.all.accept_ra and
# net.ipv6.conf.default.accept_ra are set to 0.
# Otherwise, it exits with 1.
#

# Suppress errors in case IPv6 is disabled
val_all=$(sysctl -n net.ipv6.conf.all.accept_ra 2>/dev/null)
val_default=$(sysctl -n net.ipv6.conf.default.accept_ra 2>/dev/null)

if [ "${val_all}" = "0" ] && [ "${val_default}" = "0" ]; then
  echo 0
else
  echo 1
fi