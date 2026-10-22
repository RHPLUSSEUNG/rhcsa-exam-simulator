# Reference solution — Configure UID, shell and account expiration

Use usermod for existing users and chage -E for the account expiration date. A nologin shell denies an interactive shell even though a password is assigned.

```bash
if id unilao >/dev/null 2>&1; then
  usermod -u 2334 -s /sbin/nologin unilao
else
  useradd -m -u 2334 -s /sbin/nologin unilao
fi
echo 'unilao:souspolo' | chpasswd
usermod -s /bin/bash sam
chage -E 2029-12-21 sam
```

## Verify

```bash
id unilao
getent passwd unilao sam
chage -l sam
```
