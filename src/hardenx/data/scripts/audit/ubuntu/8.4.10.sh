#!/bin/bash

auditctl -l 2>/dev/null | grep -c -- '-S mount'