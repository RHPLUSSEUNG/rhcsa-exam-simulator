#!/usr/bin/env bash
set -e
mkdir -p /opt/rhcsa-b04/rpm
mkdir -p "$RHCSA_STATE"
if rpm -q zsh >/dev/null 2>&1; then
  touch "$RHCSA_STATE/b04-rpm-url.preinstalled"
  dnf -y remove zsh >/dev/null
fi
rpmfile="$(find -L /mnt/dvd /opt/rhcsa-repo -type f -name 'zsh-[0-9]*.rpm' -print -quit 2>/dev/null || true)"
[[ -n "$rpmfile" ]] || { echo 'Attach the RHEL 10 full installation DVD: zsh RPM not found' >&2; exit 1; }
cp -f "$rpmfile" /opt/rhcsa-b04/rpm/zsh.rpm
chmod -R a+rX /opt/rhcsa-b04/rpm
cat >/etc/systemd/system/rhcsa-b04-rpm.service <<'UNIT'
[Unit]
Description=Exam 04 local RPM fixture
[Service]
ExecStart=/usr/bin/python3 -m http.server 8274 --bind 127.0.0.1 --directory /opt/rhcsa-b04/rpm
[Install]
WantedBy=multi-user.target
UNIT
systemctl daemon-reload
systemctl enable --now rhcsa-b04-rpm.service
echo 'b04-rpm-url: local zsh RPM URL is ready'
exit 0
