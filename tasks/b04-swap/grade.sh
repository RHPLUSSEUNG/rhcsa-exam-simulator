#!/usr/bin/env bash
. "$RHCSA_LIB/grade-lib.sh"
ckpt "a 400 MiB partition is active swap on the allocated disk" 6 python3 "$RHCSA_HOME/tasks/b04-swap/verify.py" runtime
ckpt "the new swap has a persistent fstab entry" 6 python3 "$RHCSA_HOME/tasks/b04-swap/verify.py" persistent
