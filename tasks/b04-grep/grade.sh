#!/usr/bin/env bash
. "$RHCSA_LIB/grade-lib.sh"
ckpt "/root/lines exists" 2 path_exists /root/lines
ckpt_expr "output exactly matches literal grep" 4 'cmp -s /root/lines <(grep -F ich /usr/share/dict/words)'
