#!/usr/bin/env bash
rm -f /etc/sudoers.d/rhcsa-b04
if [[ -f "$RHCSA_STATE/b04-users.created" ]]; then
  while read -r u; do
    case "$u" in natasha|harry|sarah|alex) userdel -r "$u" >/dev/null 2>&1 || true;; esac
  done <"$RHCSA_STATE/b04-users.created"
  rm -f "$RHCSA_STATE/b04-users.created"
fi
exit 0
