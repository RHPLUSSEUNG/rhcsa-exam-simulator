# Reference solution — Configure a specific chrony time source

Configure the requested source rather than blindly accepting a default pool. iburst accelerates initial samples when a real server is reachable.

```bash
sed -i -E '/^[[:space:]]*(server|pool)[[:space:]]/s/^/# /' /etc/chrony.conf
echo 'server ntp.example.com iburst' >>/etc/chrony.conf
systemctl enable --now chronyd
systemctl restart chronyd
```

## Verify

```bash
grep -E "^(server|pool)" /etc/chrony.conf
systemctl is-enabled chronyd
chronyc sources -v
```
