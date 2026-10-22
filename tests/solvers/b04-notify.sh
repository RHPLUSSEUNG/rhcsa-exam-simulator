#!/usr/bin/env bash
cat >/usr/local/bin/notify.sh <<'EOF'
#!/usr/bin/env bash
logger "Time for Break!"
EOF
chmod +x /usr/local/bin/notify.sh
cat >/etc/systemd/system/notify.service <<'EOF'
[Unit]
Description=Daily break notification
[Service]
Type=oneshot
ExecStart=/usr/local/bin/notify.sh
EOF
cat >/etc/systemd/system/notify.timer <<'EOF'
[Unit]
Description=Run the daily break notification
[Timer]
OnCalendar=*-*-* 07:00:00
Persistent=true
[Install]
WantedBy=timers.target
EOF
crontab -u root -l 2>/dev/null | grep -v '/usr/local/bin/notify.sh' | crontab -u root -
systemctl daemon-reload
systemctl enable --now notify.timer
