#!/usr/bin/env bash
. "$RHCSA_LIB/grade-lib.sh"
ckpt "httpd is installed" 2 pkg_installed httpd
ckpt_expr "HTTP returns the required welcome text" 5 'test "$(curl -fsS --max-time 5 http://localhost/)" = "Welcome to RHEL 10"'
ckpt "httpd is enabled and active" 3 svc_ok httpd
ckpt "HTTP is allowed at runtime" 2 firewall_service http
ckpt_expr "HTTP is allowed permanently" 2 'firewall-cmd --permanent --query-service=http'
ckpt "SELinux is enforcing" 2 selinux_enforcing
