#!/bin/bash

find / -xdev -type f \( -perm -4000 -o -perm -2000 \) -print 2>/dev/null