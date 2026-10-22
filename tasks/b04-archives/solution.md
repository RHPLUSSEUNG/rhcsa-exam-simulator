# Reference solution — Archive /usr/local with two compression formats

-j selects bzip2 and -z selects gzip. -C / gives predictable relative member paths instead of storing absolute filenames.

```bash
tar -C / -cjf /root/backup.tar.bz2 usr/local
tar -C / -czf /root/backup.tar.gz usr/local
```

## Verify

```bash
tar -tjf /root/backup.tar.bz2
tar -tzf /root/backup.tar.gz
```
