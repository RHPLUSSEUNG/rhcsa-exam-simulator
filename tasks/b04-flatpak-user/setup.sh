#!/usr/bin/env bash
mkdir -p "$RHCSA_STATE"
if ! id student >/dev/null 2>&1; then
  useradd -m student || exit 1
  touch "$RHCSA_STATE/b04-flatpak-user.student-created"
fi
dnf -y install flatpak >/dev/null 2>&1 || exit 1
bash "$RHCSA_ASSETS/build-flatpak-repo.sh" /opt/rhcsa-b04/flatpak/repo com.example.CodiumPractice || exit 1
chmod -R a+rX /opt/rhcsa-b04/flatpak
echo 'b04-flatpak-user: unsigned offline fixture ready; configure student scope'
exit 0
