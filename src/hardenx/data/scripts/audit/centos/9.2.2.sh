#!/bin/bash

awk -F: '($2 == "") { count++ } END { print count+0 }' /etc/shadow