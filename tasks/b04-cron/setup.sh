#!/usr/bin/env bash
dnf -y install cronie >/dev/null 2>&1 || exit 1
for u in natasha tom; do id "$u" >/dev/null 2>&1 || useradd -m "$u"; done
mkdir -p "$RHCSA_STATE"
for u in root natasha; do
  [[ -f "$RHCSA_STATE/b04-cron-$u.bak" ]] || crontab -u "$u" -l >"$RHCSA_STATE/b04-cron-$u.bak" 2>/dev/null || true
done
if [[ ! -e "$RHCSA_STATE/b04-cron-allow.saved" ]]; then
  [[ ! -e /etc/cron.allow ]] || cp -a /etc/cron.allow "$RHCSA_STATE/b04-cron-allow.bak"
  touch "$RHCSA_STATE/b04-cron-allow.saved"
fi
systemctl disable --now crond >/dev/null 2>&1
echo 'b04-cron: schedules and access control are not configured'
exit 0
