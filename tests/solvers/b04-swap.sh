#!/usr/bin/env bash
: "${RHCSA_HOME:=/opt/rhcsa-sim}"
: "${RHCSA_STATE:=/var/lib/rhcsa-sim}"
. "$RHCSA_HOME/tasks/b04-lvm/storage.sh"
disk="$(cat "$RHCSA_STATE/claims/shared-b04storage.dev")"
part="$(b04_partition "$disk" 400 swap)" || exit 1
mkswap "$part"
uuid="$(blkid -s UUID -o value "$part")"
echo "UUID=$uuid none swap defaults 0 0" >>/etc/fstab
swapon "$part"
