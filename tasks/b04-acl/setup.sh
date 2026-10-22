#!/usr/bin/env bash
dnf -y install acl >/dev/null 2>&1 || exit 1
for u in natasha harry; do id "$u" >/dev/null 2>&1 || useradd -m "$u"; done
groupadd -f finance
mkdir -p /groups/accounting
echo 'b04-acl: finance and accounting directory are ready'
exit 0
