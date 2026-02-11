#!/bin/bash

auditctl -s | grep "backlog_limit" | awk '{print $2}'