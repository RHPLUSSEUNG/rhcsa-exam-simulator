#!/usr/bin/env bash
. "$RHCSA_LIB/grade-lib.sh"
ckpt "unilao has UID 2334" 3 user_uid unilao 2334
ckpt "unilao password matches" 3 user_password unilao souspolo
ckpt "unilao uses nologin" 2 user_shell unilao /sbin/nologin
ckpt "sam uses bash" 2 user_shell sam /bin/bash
ckpt_expr "sam account expires on 2029-12-21" 3 'test "$(getent shadow sam | cut -d: -f8)" = "$(($(date -u -d 2029-12-21 +%s)/86400))"'
