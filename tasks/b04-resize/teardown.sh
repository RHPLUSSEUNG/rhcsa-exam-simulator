#!/usr/bin/env bash
if [[ -f "$RHCSA_STATE/b04-resize.vg-uuid" ]] && [[ "$(vgs --noheadings -o vg_uuid VG 2>/dev/null | xargs)" = "$(cat "$RHCSA_STATE/b04-resize.vg-uuid")" ]]; then
  umount /mnt/b04-vo 2>/dev/null || true
  sed -i '\#[[:space:]]/mnt/b04-vo[[:space:]]#d' /etc/fstab
  vgremove -f VG >/dev/null 2>&1 || true
  . "$RHCSA_LIB/storage-prep.sh"
  spare_cleanup
fi
rm -f "$RHCSA_STATE/b04-resize.vg-uuid" "$RHCSA_STATE/b04-resize.sha256"
rmdir /mnt/b04-vo 2>/dev/null || true
exit 0
