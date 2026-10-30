#!/usr/bin/env bash
if [[ -f "$RHCSA_STATE/b04-resize.vg-uuid" ]] && [[ "$(vgs --noheadings -o vg_uuid VG 2>/dev/null | xargs)" = "$(cat "$RHCSA_STATE/b04-resize.vg-uuid")" ]]; then
  umount /mnt/b04-vo 2>/dev/null || true
  sed -i '\#[[:space:]]/mnt/b04-vo[[:space:]]#d' /etc/fstab
  vgremove -f VG >/dev/null 2>&1 || true
fi
rm -f "$RHCSA_STATE/b04-resize.vg-uuid" "$RHCSA_STATE/b04-resize.sha256"
rmdir /mnt/b04-vo 2>/dev/null || true
disk="$(cat "$RHCSA_STATE/claims/shared-b04storage.dev" 2>/dev/null)"
if [[ -n "$disk" && -b "$disk" ]]; then
  . "$RHCSA_HOME/tasks/b04-lvm/storage.sh"
  b04_release_if_unused "$disk"
fi
exit 0
