#!/usr/bin/env bash
if [[ -f "$RHCSA_STATE/b04-ntp.conf.bak" ]]; then mv "$RHCSA_STATE/b04-ntp.conf.bak" /etc/chrony.conf; systemctl restart chronyd >/dev/null 2>&1 || true; fi
sed -i '/# rhcsa-b04-ntp$/d' /etc/hosts
exit 0
