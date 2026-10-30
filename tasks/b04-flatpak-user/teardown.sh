#!/usr/bin/env bash
home="$(getent passwd student | cut -d: -f6)"
if [[ -n "$home" ]]; then
  runuser -u student -- env HOME="$home" flatpak --user uninstall -y com.example.CodiumPractice >/dev/null 2>&1 || true
  runuser -u student -- env HOME="$home" flatpak --user remote-delete flatdb >/dev/null 2>&1 || true
fi
if [[ -f "$RHCSA_STATE/b04-flatpak-user.student-created" ]]; then
  userdel -r student >/dev/null 2>&1 || true
  rm -f "$RHCSA_STATE/b04-flatpak-user.student-created"
fi
exit 0
