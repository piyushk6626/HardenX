#!/bin/bash

find / -xdev -perm /0002 2>/dev/null | wc -l