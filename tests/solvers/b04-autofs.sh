#!/usr/bin/env bash
mkdir -p /etc/auto.master.d
echo '/data /etc/auto.b04-public' >/etc/auto.master.d/b04-public.autofs
echo 'public -rw,sync,fstype=nfs localhost:/shares/public' >/etc/auto.b04-public
systemctl enable --now autofs
systemctl restart autofs
ls /data/public/README
