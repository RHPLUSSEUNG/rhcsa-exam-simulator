#!/usr/bin/env bash
dnf -y install chrony >/dev/null 2>&1 || exit 1
[[ -f "$RHCSA_STATE/b04-ntp.conf.bak" ]] || cp -a /etc/chrony.conf "$RHCSA_STATE/b04-ntp.conf.bak"
grep -q '# rhcsa-b04-ntp$' /etc/hosts || echo '127.0.0.1 ntp.example.com # rhcsa-b04-ntp' >>/etc/hosts
systemctl disable --now chronyd >/dev/null 2>&1
echo 'b04-ntp: chrony is installed; configure ntp.example.com'
exit 0
