#!/usr/bin/env bash
. "$RHCSA_LIB/grade-lib.sh"
ckpt "sysadms group exists" 2 group_exists sysadms
ckpt "natasha belongs to sysadms" 2 user_in_group natasha sysadms
ckpt "harry belongs to sysadms" 2 user_in_group harry sysadms
ckpt "sarah uses nologin" 2 user_shell sarah /sbin/nologin
ckpt_expr "sarah is outside sysadms" 2 '! user_in_group sarah sysadms'
ckpt "natasha password matches" 2 user_password natasha trootent
ckpt "harry password matches" 2 user_password harry trootent
ckpt "sarah password matches" 2 user_password sarah trootent
ckpt "sysadms can invoke useradd" 2 python3 "$RHCSA_HOME/tasks/b04-users/verify.py" sudo natasha /usr/sbin/useradd
ckpt "harry can also invoke useradd" 2 python3 "$RHCSA_HOME/tasks/b04-users/verify.py" sudo harry /usr/sbin/useradd
ckpt "harry has passwordless passwd" 2 python3 "$RHCSA_HOME/tasks/b04-users/verify.py" sudo harry /usr/bin/passwd nopass
ckpt "alex has passwordless dnf" 2 python3 "$RHCSA_HOME/tasks/b04-users/verify.py" sudo alex /usr/bin/dnf nopass
ckpt_expr "sudoers is valid" 2 'visudo -c >/dev/null'
