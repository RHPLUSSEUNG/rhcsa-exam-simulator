#!/usr/bin/env bash
. "$RHCSA_LIB/grade-lib.sh"
ckpt_expr "bzip2 archive is valid" 2 'bzip2 -t /root/backup.tar.bz2'
ckpt_expr "gzip archive is valid" 2 'gzip -t /root/backup.tar.gz'
ckpt_expr "bzip2 archive includes the intact source fixture" 3 'cmp -s /usr/local/share/rhcsa-b04/README <(tar -xOjf /root/backup.tar.bz2 usr/local/share/rhcsa-b04/README)'
ckpt_expr "gzip archive includes the intact source fixture" 3 'cmp -s /usr/local/share/rhcsa-b04/README <(tar -xOzf /root/backup.tar.gz usr/local/share/rhcsa-b04/README)'
