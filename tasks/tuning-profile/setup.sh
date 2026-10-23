#!/usr/bin/env bash
dnf -y install tuned >/dev/null 2>&1 || exit 1
systemctl enable --now tuned >/dev/null 2>&1 || exit 1
tuned-adm off >/dev/null 2>&1 || true
rm -f /etc/tuned/active_profile
systemctl disable --now tuned >/dev/null 2>&1
echo "tuning-profile: tuned present, with no active profile, and stopped"
exit 0
