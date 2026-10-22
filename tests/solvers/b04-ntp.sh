#!/usr/bin/env bash
sed -i -E '/^[[:space:]]*(server|pool)[[:space:]]/s/^/# /' /etc/chrony.conf
echo 'server ntp.example.com iburst' >>/etc/chrony.conf
systemctl enable --now chronyd
systemctl restart chronyd
