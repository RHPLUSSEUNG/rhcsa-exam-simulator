#!/usr/bin/env bash
. "$RHCSA_LIB/grade-lib.sh"
b04_user() {
  local home
  home="$(getent passwd student | cut -d: -f6)"
  [[ -n "$home" ]] && runuser -u student -- env HOME="$home" flatpak --user "$@"
}
ckpt_expr "student remote flatdb has the required URL" 4 'b04_user remotes --columns=name,url | grep -Eq "^flatdb[[:space:]]+file:///opt/rhcsa-b04/flatpak/repo/?[[:space:]]*$"'
ckpt_expr "student app was installed from flatdb" 4 'test "$(b04_user info --show-origin com.example.CodiumPractice)" = flatdb'
ckpt_expr "flatdb is not a system remote" 2 '! flatpak remotes --system --columns=name | grep -Fxq flatdb'
ckpt_expr "practice app is not installed system-wide" 2 '! flatpak info --system com.example.CodiumPractice >/dev/null 2>&1'
