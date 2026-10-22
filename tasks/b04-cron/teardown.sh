#!/usr/bin/env bash
for u in root natasha; do
  f="$RHCSA_STATE/b04-cron-$u.bak"
  if [[ -f "$f" ]]; then crontab -u "$u" "$f" 2>/dev/null || true; rm -f "$f"; fi
done
if [[ -f "$RHCSA_STATE/b04-cron-allow.saved" ]]; then
  if [[ -f "$RHCSA_STATE/b04-cron-allow.bak" ]]; then mv "$RHCSA_STATE/b04-cron-allow.bak" /etc/cron.allow; else rm -f /etc/cron.allow; fi
  rm -f "$RHCSA_STATE/b04-cron-allow.saved"
fi
exit 0
