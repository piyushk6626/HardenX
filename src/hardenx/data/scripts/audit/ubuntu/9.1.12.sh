#!/usr/bin/env bash

find / \( -nouser -o -nogroup \) -print 2>/dev/null | wc -l