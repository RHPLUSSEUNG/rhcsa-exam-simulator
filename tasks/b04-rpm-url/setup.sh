#!/usr/bin/env bash
set -e
RPM_DIR=/opt/rhcsa-b04/rpm
RPM_FILE="$RPM_DIR/zsh.rpm"

mkdir -p "$RPM_DIR"
mkdir -p "$RHCSA_STATE"

# Remember the original package state, but do not alter it until the fixture is
# ready. This keeps a failed setup from removing a package that was already on
# the machine.
if rpm -q zsh >/dev/null 2>&1; then
  touch "$RHCSA_STATE/b04-rpm-url.preinstalled"
fi

if [[ -s "$RPM_FILE" ]]; then
  rpmfile="$RPM_FILE"
else
  rpmfile="$(find -L /mnt/dvd /mnt/cdrom /run/media /opt/rhcsa-repo /var/cache/dnf \
    -type f -name 'zsh-[0-9]*.rpm' -print -quit 2>/dev/null || true)"
fi

# A working subscribed or internet repository is a valid environment even when
# the installation DVD is not mounted. Download the fixture without installing
# it, matching the repository checks accepted by `rhcsa-sim doctor`.
if [[ -z "$rpmfile" ]]; then
  dnf download --destdir="$RPM_DIR" zsh >/dev/null 2>&1 || true
  rpmfile="$(find "$RPM_DIR" -maxdepth 1 -type f -name 'zsh-[0-9]*.rpm' -print -quit 2>/dev/null || true)"
fi

[[ -n "$rpmfile" ]] || {
  echo 'zsh RPM not found: attach the RHEL 10 full installation DVD or enable a working DNF repository' >&2
  exit 1
}

if [[ "$rpmfile" != "$RPM_FILE" ]]; then
  cp -f "$rpmfile" "$RPM_FILE"
fi
[[ -s "$RPM_FILE" ]] || { echo 'Downloaded zsh RPM is empty' >&2; exit 1; }

# Seed the exam state only after the downloadable RPM fixture is complete.
if rpm -q zsh >/dev/null 2>&1; then
  dnf -y remove zsh >/dev/null
fi

chmod -R a+rX "$RPM_DIR"
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
