#!/usr/bin/env bash
sed -i '/^[[:space:]]*GRUB_TIMEOUT=/d' /etc/default/grub
echo 'GRUB_TIMEOUT=10' >>/etc/default/grub
grub2-mkconfig -o /boot/grub2/grub.cfg
