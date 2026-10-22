#!/usr/bin/env bash
dnf -y install tar gzip bzip2 >/dev/null 2>&1 || exit 1
mkdir -p /usr/local/share/rhcsa-b04
printf 'exam 04 archive fixture\n' >/usr/local/share/rhcsa-b04/README
echo 'b04-archives: source fixture ready'
exit 0
