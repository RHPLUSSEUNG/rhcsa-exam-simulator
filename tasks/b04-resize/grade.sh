#!/usr/bin/env bash
. "$RHCSA_LIB/grade-lib.sh"
ckpt "VG/VO size is within 217..243 MiB" 4 lv_size_between /dev/VG/VO 217 243
ckpt_expr "ext4 filesystem also grew into the accepted size range" 4 'test "$(readlink -f "$(findmnt -n -o SOURCE -T /mnt/b04-vo)")" = "$(readlink -f /dev/VG/VO)" && python3 "$RHCSA_HOME/tasks/b04-resize/verify.py" /dev/VG/VO'
ckpt_expr "existing data is unchanged" 4 'sha256sum -c "$RHCSA_STATE/b04-resize.sha256" >/dev/null'
ckpt "volume is mounted persistently" 2 mount_persistent /mnt/b04-vo
