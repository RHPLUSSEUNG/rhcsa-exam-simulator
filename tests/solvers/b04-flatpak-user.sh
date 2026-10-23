#!/usr/bin/env bash
home="$(getent passwd student | cut -d: -f6)"
runuser -u student -- env HOME="$home" flatpak --user remote-add --if-not-exists --no-gpg-verify flatdb file:///opt/rhcsa-b04/flatpak/repo
runuser -u student -- env HOME="$home" flatpak --user install -y flatdb com.example.CodiumPractice
