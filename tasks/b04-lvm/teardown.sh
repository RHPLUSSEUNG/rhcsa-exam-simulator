#!/usr/bin/env bash
umount /mnt/wshare 2>/dev/null || true
sed -i '\#[[:space:]]/mnt/wshare[[:space:]]#d' /etc/fstab
# Delete only a VG backed by the disk allocated to this exercise.
disk="$(cat "$RHCSA_STATE/claims/shared-b04storage.dev" 2>/dev/null)"
if [[ -n "$disk" ]] && pvs --noheadings -o pv_name,vg_name 2>/dev/null | awk -v d="$disk" '$2=="wgroup" && index($1,d)==1{ok=1} END{exit !ok}'; then
  vgremove -f wgroup >/dev/null 2>&1 || true
fi
rmdir /mnt/wshare 2>/dev/null || true
if [[ -n "$disk" && -b "$disk" ]]; then
  . "$RHCSA_HOME/tasks/b04-lvm/storage.sh"
  b04_release_if_unused "$disk"
fi
exit 0
