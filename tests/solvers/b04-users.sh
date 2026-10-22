#!/usr/bin/env bash
groupadd -f sysadms
for u in natasha harry sarah; do id "$u" >/dev/null 2>&1 || useradd -m "$u"; done
usermod -aG sysadms natasha
usermod -aG sysadms harry
usermod -s /sbin/nologin sarah
gpasswd -d sarah sysadms 2>/dev/null || true
printf '%s\n' 'natasha:trootent' 'harry:trootent' 'sarah:trootent' | chpasswd
cat >/etc/sudoers.d/rhcsa-b04 <<'EOF'
%sysadms ALL=(ALL) /usr/sbin/useradd
harry ALL=(ALL) NOPASSWD: /usr/bin/passwd
alex ALL=(ALL) NOPASSWD: /usr/bin/dnf
EOF
chmod 0440 /etc/sudoers.d/rhcsa-b04
visudo -c
