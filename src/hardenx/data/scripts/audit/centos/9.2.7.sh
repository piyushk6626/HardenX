#!/usr/bin/env bash

cut -d: -f1 /etc/passwd | sort | uniq -d | wc -l