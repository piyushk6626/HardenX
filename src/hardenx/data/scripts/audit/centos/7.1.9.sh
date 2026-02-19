#!/bin/bash
awk -F: '$3 == 0 {a[c++]=$1} END{for(i=0;i<c;i++){printf "%s%s", a[i], (i<c-1?",":"")}}' /etc/group