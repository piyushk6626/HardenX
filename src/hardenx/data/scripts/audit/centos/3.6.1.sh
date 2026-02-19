#!/bin/bash

enabled_status=$(systemctl is-enabled crond 2>/dev/null)
active_status=$(systemctl is-active crond 2>/dev/null)

echo "${enabled_status}-${active_status}"