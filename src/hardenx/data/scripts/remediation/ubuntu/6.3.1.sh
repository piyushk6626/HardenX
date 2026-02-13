#!/usr/bin/env bash

if [[ "${1}" != "up-to-date" ]]; then
    exit 0
fi

export DEBIAN_FRONTEND=noninteractive

if apt-get update -qq >/dev/null 2>&1 && apt-get install -y -qq libpam-runtime >/dev/null 2>&1; then
    exit 0
else
    exit 1
fi