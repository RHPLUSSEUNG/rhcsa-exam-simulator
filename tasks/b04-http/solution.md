# Reference solution — Publish a persistent HTTP welcome page

Install the server, write the document, restore its policy context and configure both service and firewall persistence.

```bash
dnf -y install httpd
printf '%s\n' 'Welcome to RHEL 10' >/var/www/html/index.html
restorecon -RF /var/www/html
systemctl enable --now httpd
firewall-cmd --permanent --add-service=http
firewall-cmd --reload
```

## Verify

```bash
curl -f http://localhost/
systemctl is-enabled httpd
firewall-cmd --permanent --query-service=http
```
