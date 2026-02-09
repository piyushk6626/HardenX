#!/bin/bash

if dpkg-query -W -f='${Status}' telnet 2>/dev/null | grep -q "install ok installed"; then
    echo "installed"
else
    echo "not installed"
fi