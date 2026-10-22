#!/usr/bin/env bash
runuser -u student -- env HOME=/home/student flatpak --user remote-add --if-not-exists --no-gpg-verify flatdb file:///opt/rhcsa-b04/flatpak/repo
runuser -u student -- env HOME=/home/student flatpak --user install -y flatdb com.example.CodiumPractice
