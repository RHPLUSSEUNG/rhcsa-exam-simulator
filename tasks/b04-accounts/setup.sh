#!/usr/bin/env bash
mkdir -p "$RHCSA_STATE"
if [[ ! -e "$RHCSA_STATE/b04-accounts.saved" ]]; then
  id unilao >/dev/null 2>&1 || touch "$RHCSA_STATE/b04-accounts.unilao-new"
  if id sam >/dev/null 2>&1; then
    getent passwd sam | cut -d: -f7 >"$RHCSA_STATE/b04-accounts.sam-shell"
    getent shadow sam | cut -d: -f8 >"$RHCSA_STATE/b04-accounts.sam-expire"
  else
    useradd -m -s /sbin/nologin sam || exit 1
    touch "$RHCSA_STATE/b04-accounts.sam-new"
  fi
  touch "$RHCSA_STATE/b04-accounts.saved"
fi
usermod -s /sbin/nologin sam || exit 1
chage -E -1 sam || exit 1
echo 'b04-accounts: sam exists; configure the accounts'
exit 0
