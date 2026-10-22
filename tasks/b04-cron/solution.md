# Reference solution — Configure cron schedules and access control

cron.allow controls access to the crontab command, not whether already-installed jobs run. Root installs natasha's schedules before restricting unprivileged administration.

```bash
for u in natasha tom; do id "$u" >/dev/null 2>&1 || useradd -m "$u"; done
{ crontab -u natasha -l 2>/dev/null; cat <<'EOF'
*/2 * * * * /usr/bin/logger "EX200 in progress"
30 12 * * * /bin/echo "Hello World" >> /home/natasha/hello.log
EOF
} | crontab -u natasha -
{ crontab -u root -l 2>/dev/null; echo '45 0 * * * /usr/bin/find /tmp -type f -empty -delete'; } | crontab -u root -
printf 'tom\n' >/etc/cron.allow
systemctl enable --now crond
```

## Verify

```bash
crontab -u natasha -l
crontab -u root -l
cat /etc/cron.allow
```
