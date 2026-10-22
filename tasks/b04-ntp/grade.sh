#!/usr/bin/env bash
. "$RHCSA_LIB/grade-lib.sh"
ckpt_expr "ntp.example.com uses iburst" 4 'grep -Ev "^[[:space:]]*(#|$)" /etc/chrony.conf | grep -Eq "^(server|pool)[[:space:]]+ntp\.example\.com[[:space:]].*\biburst\b"'
ckpt "chronyd is enabled and active" 4 svc_ok chronyd
