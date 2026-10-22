#!/usr/bin/env bash
printf 'preserve this existing log line\n' >/var/log/system-check.log
echo 'b04-system-check: existing log content must be preserved'
exit 0
