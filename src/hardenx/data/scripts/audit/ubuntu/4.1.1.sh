#!/bin/bash

sysctl -n net.ipv6.conf.all.disable_ipv6 | awk '{print $NF}'