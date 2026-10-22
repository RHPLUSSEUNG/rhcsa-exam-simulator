#!/usr/bin/env bash
mkdir -p "$RHCSA_STATE"
[[ -f "$RHCSA_STATE/b04-notify.cron.bak" ]] || crontab -u root -l >"$RHCSA_STATE/b04-notify.cron.bak" 2>/dev/null || true
{ crontab -u root -l 2>/dev/null | grep -v '/usr/local/bin/notify.sh'; echo '0 7 * * * /usr/local/bin/notify.sh'; } | crontab -u root -
echo 'b04-notify: replace the provided cron entry with a timer'
exit 0
