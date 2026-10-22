#!/usr/bin/env bash
if [[ -f "$RHCSA_STATE/b04-grub.bak" ]]; then
  mv "$RHCSA_STATE/b04-grub.bak" /etc/default/grub
  grub2-mkconfig -o /boot/grub2/grub.cfg >/dev/null 2>&1 || true
fi
exit 0
