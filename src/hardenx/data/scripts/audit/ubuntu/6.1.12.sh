#!/usr/bin/env bash

sshd -T | grep '^kexalgorithms ' | awk '{print $2}'