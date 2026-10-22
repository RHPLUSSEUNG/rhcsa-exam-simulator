#!/usr/bin/env bash
[[ ! -f "$RHCSA_STATE/b04-accounts.unilao-new" ]] || userdel -r unilao >/dev/null 2>&1 || true
if [[ -f "$RHCSA_STATE/b04-accounts.sam-new" ]]; then
  userdel -r sam >/dev/null 2>&1 || true
elif [[ -f "$RHCSA_STATE/b04-accounts.sam-shell" ]]; then
  usermod -s "$(cat "$RHCSA_STATE/b04-accounts.sam-shell")" sam 2>/dev/null || true
  expiry="$(cat "$RHCSA_STATE/b04-accounts.sam-expire")"
  chage -E "${expiry:--1}" sam 2>/dev/null || true
fi
rm -f "$RHCSA_STATE"/b04-accounts.*
exit 0
