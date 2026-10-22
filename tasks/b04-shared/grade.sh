#!/usr/bin/env bash
. "$RHCSA_LIB/grade-lib.sh"
ckpt "collaborative directory exists" 2 is_dir /home/manager
ckpt "collaborative owner is root" 2 file_owner /home/manager root
ckpt "collaborative group is sysadms" 2 file_group /home/manager sysadms
ckpt "collaborative mode is 2770" 3 file_mode /home/manager 2770
ckpt "sticky shared directory exists" 1 is_dir /shared/projects
ckpt "shared directory mode is 1777" 4 file_mode /shared/projects 1777
