#!/bin/bash
sudo sshd -T | grep -i '^permitemptypasswords' | awk '{print $2}'