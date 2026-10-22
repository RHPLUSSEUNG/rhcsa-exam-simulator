#!/usr/bin/env bash
[[ -f "$RHCSA_STATE/b04-grub.bak" ]] || cp -a /etc/default/grub "$RHCSA_STATE/b04-grub.bak"
echo 'b04-grub-timeout: set the source and regenerate the active configuration'
exit 0
