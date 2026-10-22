#!/usr/bin/env bash
. "$RHCSA_LIB/grade-lib.sh"
ckpt "system-check script appends the current date" 4 python3 "$RHCSA_HOME/tasks/b04-notify/verify.py" append
ckpt "system-check.service runs the script as oneshot" 3 python3 "$RHCSA_HOME/tasks/b04-notify/verify.py" check-service
ckpt "system-check.timer repeats once per minute" 3 python3 "$RHCSA_HOME/tasks/b04-notify/verify.py" minute
ckpt "system-check.timer is enabled and active" 3 svc_ok system-check.timer
ckpt_expr "existing log content is preserved" 2 'grep -Fxq "preserve this existing log line" /var/log/system-check.log'
