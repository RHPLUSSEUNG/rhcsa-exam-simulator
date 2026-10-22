#!/usr/bin/env bash
cat >/usr/local/bin/system-check.sh <<'EOF'
#!/usr/bin/env bash
date >> /var/log/system-check.log
EOF
chmod +x /usr/local/bin/system-check.sh
cat >/etc/systemd/system/system-check.service <<'EOF'
[Unit]
Description=Append the current date to the system check log
[Service]
Type=oneshot
ExecStart=/usr/local/bin/system-check.sh
EOF
cat >/etc/systemd/system/system-check.timer <<'EOF'
[Unit]
Description=Run the system check once per minute
[Timer]
OnCalendar=*-*-* *:*:00
Persistent=true
[Install]
WantedBy=timers.target
EOF
systemctl daemon-reload
systemctl enable --now system-check.timer
