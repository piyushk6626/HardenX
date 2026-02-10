#!/usr/bin/env bash

sudo ufw status verbose | grep "Default:" | sed -n 's/.*, \(allow\|deny\) (outgoing).*/\1/p'