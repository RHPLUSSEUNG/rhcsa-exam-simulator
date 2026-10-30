# Reference solution — logical volume (VFAT)

This spare disk is shared with the swap and resize tasks, so **add** a partition
(do not re-label the whole disk). It is a **GPT** disk (RHCSA 10 partitions GPT
only). Partition 1 already holds the existing `myvol` volume group; put myvg on
/dev/vdb2 (swap goes on vdb3).

> Note: use the spare disk on this system (run `lsblk`; here it is `/dev/vdb`).

> Practising this task on its own? If `lsblk` shows the disk has **no partitions yet**,
> create the GPT label first — in fdisk type `g` — then use partition number `1`
> (on a blank disk a plain `n` would silently create an MBR label instead).

```bash
fdisk /dev/vdb
   # n -> 2 -> <enter> -> +810M          (~810 MiB: 50 x 16 MiB extents + metadata; GPT has no primary/extended)
   # t -> 2 -> lvm                       (type alias: Linux LVM)
   # w
udevadm settle
vgcreate -s 16M myvg /dev/vdb2          # 16 MiB physical-extent size
lvcreate -l 50 -n mylv myvg            # 50 extents = 800 MiB
mkfs.vfat /dev/myvg/mylv               # 'dnf install dosfstools' first if mkfs.vfat is missing
mkdir /mnt/mydata
echo "UUID=$(blkid -s UUID -o value /dev/myvg/mylv)  /mnt/mydata  vfat  defaults,nofail  0 0" >> /etc/fstab   # nofail = boot won't drop to emergency mode if the device is ever missing
mount -a
lsblk --fs                             # verify /mnt/mydata is mounted (vfat)
```
