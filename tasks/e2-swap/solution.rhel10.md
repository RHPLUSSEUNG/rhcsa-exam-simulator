# Reference solution — swap partition

This spare disk is shared with the LVM tasks, so **add** a partition (do not
re-label the whole disk). It is a **GPT** disk (RHCSA 10 partitions GPT only).
Partition 1 already holds the existing `myvol` volume group (the resize task)
and the new `myvg` goes on partition 2; put swap on /dev/vdb, partition 3.

> Note: use the spare disk on this system (run `lsblk`; here it is `/dev/vdb`).

> Practising this task on its own? If `lsblk` shows the disk has **no partitions yet**,
> create the GPT label first — in fdisk type `g` — then use partition number `1`
> (on a blank disk a plain `n` would silently create an MBR label instead).

```bash
fdisk /dev/vdb
   # n -> 3 -> <enter> -> +512M          (new 512 MiB partition; GPT has no primary/extended)
   # t -> 3 -> swap                      (type alias: Linux swap)
   # w
udevadm settle
mkswap /dev/vdb3
# make it persistent by UUID (don't disturb existing fstab lines):
echo "UUID=$(blkid -s UUID -o value /dev/vdb3)  swap  swap  defaults,nofail  0 0" >> /etc/fstab
swapon -a
free -m        # verify the total swap increased by ~512 MiB
```
