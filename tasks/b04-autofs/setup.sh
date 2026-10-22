#!/usr/bin/env bash
dnf -y install autofs nfs-utils >/dev/null 2>&1 || exit 1
mkdir -p /shares/public /etc/exports.d
printf 'public training share\n' >/shares/public/README
chmod 0777 /shares/public
echo '/shares/public 127.0.0.1(rw,sync,no_root_squash)' >/etc/exports.d/rhcsa-b04.exports
systemctl enable --now nfs-server >/dev/null 2>&1 || exit 1
exportfs -ra || exit 1
echo 'b04-autofs: localhost:/shares/public is available; configure the client'
exit 0
