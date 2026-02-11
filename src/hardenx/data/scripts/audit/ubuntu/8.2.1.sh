#!/bin/bash

if dpkg-query -W -f='${Status}' auditd 2>/dev/null | grep -q "install ok installed" && \
   dpkg-query -W -f='${Status}' audispd-plugins 2>/dev/null | grep -q "install ok installed"; then
    echo "Installed"
else
    echo "Not Installed"
fi