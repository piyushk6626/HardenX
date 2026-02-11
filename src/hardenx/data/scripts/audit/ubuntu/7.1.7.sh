#!/bin/bash

awk -F: '($3 == 0) && ($1 != "root") {count++} END {print count+0}' /etc/passwd