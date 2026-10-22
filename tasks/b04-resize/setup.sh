#!/usr/bin/env bash
set -e
. "$RHCSA_LIB/storage-prep.sh"
dev="$(ensure_spare_disk)"
if ! vgs VG >/dev/null 2>&1; then
  pvcreate "$dev"
  vgcreate VG "$dev"
  vgs --noheadings -o vg_uuid VG | xargs >"$RHCSA_STATE/b04-resize.vg-uuid"
elif [[ ! -f "$RHCSA_STATE/b04-resize.vg-uuid" ]] || [[ "$(vgs --noheadings -o vg_uuid VG | xargs)" != "$(cat "$RHCSA_STATE/b04-resize.vg-uuid")" ]]; then
  echo 'Refusing to reuse an unrelated VG named VG' >&2; exit 1
fi
if ! lvs VG/VO >/dev/null 2>&1; then
  lvcreate -L 200M -n VO VG
  mkfs.ext4 /dev/VG/VO
fi
mkdir -p /mnt/b04-vo
grep -qE '^[^#]+[[:space:]]/mnt/b04-vo[[:space:]]' /etc/fstab || echo '/dev/VG/VO /mnt/b04-vo ext4 defaults,nofail 0 0' >>/etc/fstab
mountpoint -q /mnt/b04-vo || mount /mnt/b04-vo
if [[ ! -f "$RHCSA_STATE/b04-resize.sha256" ]]; then
  printf 'retain this existing volume content\n' >/mnt/b04-vo/important.txt
  sha256sum /mnt/b04-vo/important.txt >"$RHCSA_STATE/b04-resize.sha256"
fi
echo 'b04-resize: seeded an existing 200 MiB ext4 LV'
exit 0
