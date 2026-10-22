#!/usr/bin/env bash
. "$RHCSA_LIB/grade-lib.sh"
ckpt "notify script logs the required message" 4 python3 "$RHCSA_HOME/tasks/b04-notify/verify.py" script
ckpt "notify.service runs the script as oneshot" 3 python3 "$RHCSA_HOME/tasks/b04-notify/verify.py" service
ckpt "notify.timer schedules daily 07:00" 3 python3 "$RHCSA_HOME/tasks/b04-notify/verify.py" daily
ckpt "notify.timer is enabled and active" 3 svc_ok notify.timer
ckpt_expr "legacy notify cron entry is absent" 2 '! crontab -u root -l 2>/dev/null | grep -Ev "^[[:space:]]*#" | grep -q /usr/local/bin/notify.sh'
