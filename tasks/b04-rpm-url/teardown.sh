#!/usr/bin/env bash
systemctl disable --now rhcsa-b04-rpm.service >/dev/null 2>&1 || true
rm -f /etc/systemd/system/rhcsa-b04-rpm.service
rm -rf /opt/rhcsa-b04/rpm
systemctl daemon-reload
if [[ -f "$RHCSA_STATE/b04-rpm-url.preinstalled" ]]; then
  dnf -y install zsh >/dev/null 2>&1 || true
  rm -f "$RHCSA_STATE/b04-rpm-url.preinstalled"
fi
exit 0
