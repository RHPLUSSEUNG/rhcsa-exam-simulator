# Reference solution — Create the wgroup/wshare ext4 logical volume

8 MiB times 50 extents is 400 MiB. Create a new GPT partition without relabeling a disk that already has the swap partition. The automated solver chooses a free partition number; the reference below shows the interactive fdisk procedure.

```bash
lsblk
# Replace /dev/vdb with the actual shared spare disk shown by the lab.
fdisk /dev/vdb
# n: add a partition, accept the next free number/start, enter +480M.
# t: select the new partition and the Linux LVM type, then w.
# Do NOT use g to replace an existing partition table containing swap.
part=/dev/vdb2  # Replace with the NEW partition from lsblk.
pvcreate "$part"
vgcreate -s 8M wgroup "$part"
lvcreate -l 50 -n wshare wgroup
mkfs.ext4 /dev/wgroup/wshare
mkdir -p /mnt/wshare
uuid="$(blkid -s UUID -o value /dev/wgroup/wshare)"
echo "UUID=$uuid /mnt/wshare ext4 defaults,nofail 0 0" >>/etc/fstab
systemctl daemon-reload
mount /mnt/wshare
```

## Verify

```bash
vgs wgroup
lvs wgroup/wshare
findmnt /mnt/wshare
```
