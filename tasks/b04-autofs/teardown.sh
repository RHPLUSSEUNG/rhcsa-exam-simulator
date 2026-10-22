#!/usr/bin/env bash
umount /data/public 2>/dev/null || true
rm -f /etc/auto.master.d/b04-public.autofs /etc/auto.b04-public /etc/exports.d/rhcsa-b04.exports
exportfs -ra >/dev/null 2>&1 || true
systemctl try-restart autofs >/dev/null 2>&1 || true
exit 0
