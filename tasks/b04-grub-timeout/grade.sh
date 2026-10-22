#!/usr/bin/env bash
. "$RHCSA_LIB/grade-lib.sh"
ckpt_expr "GRUB source timeout is 10" 3 'test "$(sed -n "s/^[[:space:]]*GRUB_TIMEOUT=//p" /etc/default/grub | tr -d "\"\047[:space:]")" = 10'
ckpt_expr "generated GRUB configuration applies timeout 10" 4 'grep -Eq "^[[:space:]]*set[[:space:]]+timeout=10([[:space:]]|$)" /boot/grub2/grub.cfg'
