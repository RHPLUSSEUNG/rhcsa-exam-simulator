#!/usr/bin/env bash
. "$RHCSA_LIB/grade-lib.sh"
ckpt "wgroup uses 8 MiB extents" 3 vg_extent_size wgroup 8
ckpt "wshare exists" 2 lv_exists wgroup wshare
b04_exact_size() { lvs --noheadings --units b --nosuffix -o lv_size /dev/wgroup/wshare | awk 'NF {n++; size=$1} END {exit !(n==1 && size==419430400)}'; }
ckpt "wshare has exactly 50 extents" 3 b04_exact_size
ckpt "wshare uses ext4" 3 fs_type /mnt/wshare ext4
ckpt_expr "wshare is the mounted volume" 2 'test "$(readlink -f "$(findmnt -n -o SOURCE -T /mnt/wshare)")" = "$(readlink -f /dev/wgroup/wshare)"'
ckpt "wshare is mounted persistently" 3 mount_persistent /mnt/wshare
