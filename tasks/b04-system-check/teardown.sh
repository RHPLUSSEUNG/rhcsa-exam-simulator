#!/usr/bin/env bash
systemctl disable --now system-check.timer >/dev/null 2>&1 || true
rm -f /etc/systemd/system/system-check.service /etc/systemd/system/system-check.timer /usr/local/bin/system-check.sh /var/log/system-check.log
systemctl daemon-reload
exit 0
