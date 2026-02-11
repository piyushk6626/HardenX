#!/usr/bin/env bash

awk -F: '{ gids[$3]++ } END { count=0; for (gid in gids) if (gids[gid] > 1) count++; print count }' /etc/group