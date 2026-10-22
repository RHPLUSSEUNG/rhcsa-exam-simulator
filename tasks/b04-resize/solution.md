# Reference solution — Resize VG/VO without losing data

230M is an absolute target; +230M adds that much to the current size. -r grows ext4 together with the LV. The accepted tolerance accounts for extent rounding.

```bash
lvextend -r -L 230M /dev/VG/VO
```

## Verify

```bash
lvs VG/VO
df -h /mnt/b04-vo
cat /mnt/b04-vo/important.txt
```
