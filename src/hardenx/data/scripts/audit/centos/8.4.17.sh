#!/bin/bash

if grep -qsr -- "-a always,exit -F arch=b64 -S chacl -F auid>=1000 -F auid!=4294967295 -k perm_mod" /etc/audit/rules.d/ && \
   grep -qsr -- "-a always,exit -F arch=b32 -S chacl -F auid>=1000 -F auid!=4294967295 -k perm_mod" /etc/audit/rules.d/ && \
   grep -qsr -- "-a always,exit -F arch=b64 -S chacl -F auid=0 -k perm_mod" /etc/audit/rules.d/ && \
   grep -qsr -- "-a always,exit -F arch=b32 -S chacl -F auid=0 -k perm_mod" /etc/audit/rules.d/
then
    echo "present"
else
    echo "absent"
fi