#!/usr/bin/env bash
dnf -y install httpd curl >/dev/null 2>&1 || exit 1
mkdir -p /var/www/html
systemctl disable --now httpd >/dev/null 2>&1
printf 'Unconfigured training page\n' >/var/www/html/index.html
firewall-cmd --permanent --remove-service=http >/dev/null 2>&1 || true
firewall-cmd --remove-service=http >/dev/null 2>&1 || true
echo 'b04-http: configure the welcome page, service and firewall'
exit 0
