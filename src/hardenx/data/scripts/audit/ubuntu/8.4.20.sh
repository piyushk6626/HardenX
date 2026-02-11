#!/usr/bin/env bash
auditctl -s | grep 'enabled' | awk '{print $2}'