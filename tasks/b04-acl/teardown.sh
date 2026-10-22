#!/usr/bin/env bash
rm -f /var/tmp/fstab
setfacl -x g:finance,d:g:finance /groups/accounting 2>/dev/null || true
exit 0
