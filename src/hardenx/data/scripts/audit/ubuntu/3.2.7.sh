#!/usr/bin/env bash

timedatectl | awk '/NTP service:/ {print $NF}'