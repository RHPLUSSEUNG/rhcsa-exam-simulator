# Reference solution — Add a persistent 400 MiB swap partition

Append the new swap entry to fstab; using > would overwrite the entire file. Use the new partition, not an existing LVM partition, and do not run swapoff -a.

```bash
lsblk
fdisk /dev/vdb  # Substitute the actual shared spare disk.
# n: add the NEXT free partition with size +400M; t: Linux swap; w: save.
# Never replace a partition table that contains the wgroup PV.
part=/dev/vdb2  # Substitute the newly created partition identified with lsblk.
mkswap "$part"
uuid="$(blkid -s UUID -o value "$part")"
echo "UUID=$uuid none swap defaults 0 0" >>/etc/fstab
swapon "$part"
```

## Verify

```bash
swapon --show
findmnt --verify
```
