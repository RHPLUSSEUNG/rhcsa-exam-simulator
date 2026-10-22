# Reference solution — Configure collaborative and sticky directories

set-GID controls inherited group ownership. The sticky bit controls removal in a writable directory; it does not replace ordinary read/write permissions.

```bash
mkdir -p /home/manager /shared/projects
chown root:sysadms /home/manager
chmod 2770 /home/manager
chmod 1777 /shared/projects
```

## Verify

```bash
ls -ld /home/manager /shared/projects
```
