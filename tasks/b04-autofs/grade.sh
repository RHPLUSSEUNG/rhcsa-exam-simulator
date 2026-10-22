#!/usr/bin/env bash
. "$RHCSA_LIB/grade-lib.sh"
ckpt "autofs is enabled and active" 3 svc_ok autofs
ckpt_expr "access mounts the provided NFS share" 4 'timeout 15 ls /data/public/README >/dev/null && findmnt -rn -T /data/public -o SOURCE,FSTYPE | grep -Eq "localhost:/shares/public[[:space:]]+nfs4?$"'
ckpt_expr "public share is read-write" 2 'findmnt -rn -T /data/public -o OPTIONS | tr "," "\n" | grep -qx rw'
ckpt "public is configured through an autofs map" 3 python3 "$RHCSA_HOME/tasks/b04-autofs/verify.py"
