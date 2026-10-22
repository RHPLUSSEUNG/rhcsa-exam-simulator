#!/usr/bin/env bash
dnf -y install httpd
printf '%s\n' 'Welcome to RHEL 10' >/var/www/html/index.html
restorecon -RF /var/www/html
systemctl enable --now httpd
firewall-cmd --permanent --add-service=http
firewall-cmd --reload
