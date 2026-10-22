#!/usr/bin/env bash
id natasha >/dev/null 2>&1 || useradd -m natasha
mkdir -p /opt/rhcsa-b04/findsrc/owned
printf 'owned training file\n' >/opt/rhcsa-b04/findsrc/owned/natasha-note
printf 'other owner\n' >/opt/rhcsa-b04/findsrc/not-natasha
truncate -s 6M /opt/rhcsa-b04/findsrc/large.dat
truncate -s 3M /opt/rhcsa-b04/findsrc/small.dat
chown -R natasha /opt/rhcsa-b04/findsrc/owned
echo 'b04-find: ownership and size fixtures ready'
exit 0
