#!/usr/bin/env bash

listeners=$(ss -tlnH 'sport = :25')

if [ -z "$listeners" ]; then
    echo "not-listening"
    exit 0
fi

if echo "$listeners" | awk '{print $4}' | grep -qvE '^(127\.0\.0\.1:|\[::1\]:)'; then
    echo "network-listening"
else
    echo "local-only"
fi