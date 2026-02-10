#!/usr/bin/env bash

ufw status verbose | grep 'Default' | sed 's/Default: //' | cut -d',' -f1,2