#!/usr/bin/env bash
. "$RHCSA_LIB/grade-lib.sh"
ckpt "ntp.example.com is the only source and uses iburst" 4 python3 "$RHCSA_HOME/tasks/b04-ntp/verify.py"
ckpt "chronyd is enabled and active" 4 svc_ok chronyd
