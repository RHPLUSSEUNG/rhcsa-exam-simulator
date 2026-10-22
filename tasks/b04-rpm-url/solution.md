# Reference solution — Install zsh from the supplied RPM URL

Use dnf with the URL as its package argument. The local HTTP server is a prerequisite fixture, separate from the candidate's port-80 httpd task. Dependencies are resolved using the DVD repositories.

```bash
dnf -y install http://127.0.0.1:8274/zsh.rpm
```

## Verify

```bash
rpm -q zsh
zsh --version
```
