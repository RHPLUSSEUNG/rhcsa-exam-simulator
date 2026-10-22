#!/usr/bin/env bash
runuser -u student -- env HOME=/home/student flatpak --user uninstall -y com.example.CodiumPractice >/dev/null 2>&1 || true
runuser -u student -- env HOME=/home/student flatpak --user remote-delete flatdb >/dev/null 2>&1 || true
exit 0
