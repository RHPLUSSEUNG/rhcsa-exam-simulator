#!/usr/bin/env bash
if id unilao >/dev/null 2>&1; then
  usermod -u 2334 -s /sbin/nologin unilao
else
  useradd -m -u 2334 -s /sbin/nologin unilao
fi
echo 'unilao:souspolo' | chpasswd
usermod -s /bin/bash sam
chage -E 2029-12-21 sam
