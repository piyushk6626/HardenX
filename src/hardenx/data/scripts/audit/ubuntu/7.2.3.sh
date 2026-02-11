#!/bin/bash

grep '^UMASK' /etc/login.defs | awk '{print $2}'