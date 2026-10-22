#!/usr/bin/env bash
disk="$(cat "$RHCSA_STATE/claims/shared-b04storage.dev" 2>/dev/null)"
if [[ -n "$disk" ]]; then
  while read -r part; do
    [[ -b "$part" ]] || continue
    if [[ "$(blkid -s TYPE -o value "$part" 2>/dev/null)" == swap ]]; then
      uuid="$(blkid -s UUID -o value "$part")"
      swapoff "$part" 2>/dev/null || true
      [[ -z "$uuid" ]] || sed -i "\#^[[:space:]]*UUID=$uuid[[:space:]]#d" /etc/fstab
      sed -i "\#^[[:space:]]*$part[[:space:]]#d" /etc/fstab
    fi
  done < <(lsblk -nrpo NAME,TYPE "$disk" | awk '$2=="part"{print $1}')
  . "$RHCSA_HOME/tasks/b04-lvm/storage.sh"
  b04_release_if_unused "$disk"
fi
exit 0
