#!/usr/bin/env bash
. "$RHCSA_LIB/grade-lib.sh"
ckpt_expr "fstab contents match the original" 2 'cmp -s /etc/fstab /var/tmp/fstab'
ckpt "fstab copy is owned by root" 1 file_owner /var/tmp/fstab root
ckpt "fstab copy group is root" 1 file_group /var/tmp/fstab root
ckpt_expr "no execute bits are set" 2 'test -f /var/tmp/fstab && test "$(( 8#$(stat -c %a /var/tmp/fstab) & 0111 ))" -eq 0'
ckpt "named ACLs and masks grant the requested effective rights" 4 python3 "$RHCSA_HOME/tasks/b04-acl/verify.py"
ckpt "finance has current and default r-x ACLs" 4 python3 "$RHCSA_HOME/tasks/b04-acl/verify.py" finance
