#!/usr/bin/env bash
mkdir -p "$RHCSA_STATE"
touch "$RHCSA_STATE/b04-users.created"
for u in natasha harry sarah alex; do
  if ! id "$u" >/dev/null 2>&1; then
    useradd -m "$u" || exit 1
    echo "$u" >>"$RHCSA_STATE/b04-users.created"
  fi
done
rm -f /etc/sudoers.d/rhcsa-b04
echo 'b04-users: prerequisite accounts exist; configure memberships, passwords and sudo'
exit 0
