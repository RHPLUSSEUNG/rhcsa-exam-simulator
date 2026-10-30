#!/usr/bin/env bash
. "$RHCSA_LIB/storage-prep.sh"
DEV="$(ensure_shared_disk f08storage)" || exit 1
# ADD a swap partition beside wgroup's partition 1 — never re-label the shared disk.
pre="$(lsblk -rno NAME "$DEV" 2>/dev/null | tail -n +2 | sort)"
echo ',600M,S' | sfdisk --no-reread --force -q -a "$DEV" >/dev/null 2>&1
# partx -a registers the NEW partition even while partition 1 is in use.
partx -a "$DEV" >/dev/null 2>&1; partprobe "$DEV" >/dev/null 2>&1; udevadm settle 2>/dev/null; sleep 1
P="/dev/$(comm -13 <(echo "$pre") <(lsblk -rno NAME "$DEV" 2>/dev/null | tail -n +2 | sort) | head -1)"
[ -b "$P" ] || exit 1
mkswap "$P" >/dev/null 2>&1
grep -q "$P" /etc/fstab || echo "$P swap swap defaults,nofail 0 0" >> /etc/fstab
swapon "$P" 2>/dev/null
