#!/usr/bin/env bash
[[ -f "$RHCSA_STATE/b04-grub.bak" ]] || cp -a /etc/default/grub "$RHCSA_STATE/b04-grub.bak"
sed -i '/^[[:space:]]*GRUB_TIMEOUT=/d' /etc/default/grub
echo 'GRUB_TIMEOUT=5' >>/etc/default/grub
grub2-mkconfig -o /boot/grub2/grub.cfg >/dev/null 2>&1 || exit 1
echo 'b04-grub-timeout: set the source and regenerate the active configuration'
exit 0
