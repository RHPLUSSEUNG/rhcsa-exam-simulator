#!/usr/bin/env bash
: "${RHCSA_HOME:=/opt/rhcsa-sim}"
: "${RHCSA_STATE:=/var/lib/rhcsa-sim}"
. "$RHCSA_HOME/tasks/b04-lvm/storage.sh"
disk="$(cat "$RHCSA_STATE/claims/shared-b04storage.dev")"
part="$(b04_partition "$disk" 480 lvm)" || exit 1
pvcreate "$part"
vgcreate -s 8M wgroup "$part"
lvcreate -l 50 -n wshare wgroup
mkfs.ext4 /dev/wgroup/wshare
mkdir -p /mnt/wshare
uuid="$(blkid -s UUID -o value /dev/wgroup/wshare)"
echo "UUID=$uuid /mnt/wshare ext4 defaults,nofail 0 0" >>/etc/fstab
systemctl daemon-reload
mount /mnt/wshare
