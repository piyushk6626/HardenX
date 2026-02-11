#!/usr/bin/env bash

auditctl -s | awk '/^mode/ {print $2}'
