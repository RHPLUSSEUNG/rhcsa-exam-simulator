# Reference solution — Configure a specific chrony time source

Comment out the default server and pool lines, then configure the requested source. iburst accelerates initial samples when a real server is reachable.

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
