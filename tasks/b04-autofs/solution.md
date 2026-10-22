# Reference solution — Automount the public NFS share

The master map registers /data and its map file. The public key chooses the NFS source. Access triggers a mount; an /etc/fstab entry alone does not implement automounting.

```bash
mkdir -p /etc/auto.master.d
echo '/data /etc/auto.b04-public' >/etc/auto.master.d/b04-public.autofs
echo 'public -rw,sync,fstype=nfs localhost:/shares/public' >/etc/auto.b04-public
systemctl enable --now autofs
systemctl restart autofs
ls /data/public/README
```

## Verify

```bash
automount -m
findmnt -T /data/public
```
