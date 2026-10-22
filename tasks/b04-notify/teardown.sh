#!/usr/bin/env bash
systemctl disable --now notify.timer >/dev/null 2>&1 || true
rm -f /etc/systemd/system/notify.service /etc/systemd/system/notify.timer /usr/local/bin/notify.sh
systemctl daemon-reload
if [[ -f "$RHCSA_STATE/b04-notify.cron.bak" ]]; then crontab -u root "$RHCSA_STATE/b04-notify.cron.bak"; rm -f "$RHCSA_STATE/b04-notify.cron.bak"; fi
exit 0
