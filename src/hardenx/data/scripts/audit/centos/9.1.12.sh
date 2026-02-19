#!/bin/bash

find / -xdev \( -nouser -o -nogroup \) 2>/dev/null | wc -l