#!/bin/bash

cut -d: -f3 /etc/passwd | sort | uniq -d | wc -l