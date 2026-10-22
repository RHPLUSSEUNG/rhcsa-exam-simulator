#!/usr/bin/env bash
. "$RHCSA_LIB/grade-lib.sh"
ckpt_expr "owned directory was copied with its path" 3 'test -d /root/natashafiles/opt/rhcsa-b04/findsrc/owned'
ckpt_expr "owned file content was copied" 3 'cmp -s /opt/rhcsa-b04/findsrc/owned/natasha-note /root/natashafiles/opt/rhcsa-b04/findsrc/owned/natasha-note'
ckpt_expr "large file was copied intact" 4 'cmp -s /opt/rhcsa-b04/findsrc/large.dat /find/5mfiles/large.dat'
ckpt_expr "small file was excluded" 2 'test ! -e /find/5mfiles/small.dat'
