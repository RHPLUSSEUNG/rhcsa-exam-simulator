#!/usr/bin/env bash
. "$RHCSA_LIB/grade-lib.sh"
ckpt "natasha has the two-minute logger schedule" 3 python3 "$RHCSA_HOME/tasks/b04-cron/verify.py" logger
ckpt "natasha has the daily appended greeting" 3 python3 "$RHCSA_HOME/tasks/b04-cron/verify.py" greeting
ckpt "root has the daily empty-file cleanup" 3 python3 "$RHCSA_HOME/tasks/b04-cron/verify.py" cleanup
ckpt "only tom is allowed in cron.allow" 3 python3 "$RHCSA_HOME/tasks/b04-cron/verify.py" allow
ckpt "crond is enabled and active" 4 svc_ok crond
