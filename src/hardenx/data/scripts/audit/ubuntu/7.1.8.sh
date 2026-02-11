#!/bin/bash

awk -F: '$4 == 0 {print $1}' /etc/passwd