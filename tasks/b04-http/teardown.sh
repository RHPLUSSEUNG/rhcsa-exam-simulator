#!/usr/bin/env bash
systemctl disable --now httpd >/dev/null 2>&1 || true
rm -f /var/www/html/index.html
firewall-cmd --permanent --remove-service=http >/dev/null 2>&1 || true
firewall-cmd --remove-service=http >/dev/null 2>&1 || true
exit 0
