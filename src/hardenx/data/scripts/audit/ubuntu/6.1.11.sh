#!/usr/bin/env bash

sshd -T | awk '/^ignorerhosts / {print $2}'