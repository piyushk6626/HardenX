#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "false"
    exit 1
fi

case "$1" in
    Enabled)
        authconfig --enablepwhistory --update
        ;;
    Disabled)
        authconfig --disablepwhistory --update
        ;;
    *)
        echo "false"
        exit 1
        ;;
esac

if [ $? -eq 0 ]; then
    echo "true"
else
    echo "false"
fi