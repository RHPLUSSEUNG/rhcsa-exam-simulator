# Reference solution — Extract the matching dictionary lines

Use a literal, case-sensitive match and overwrite the output with >. Do not prepend filenames, line numbers or a count.

```bash
grep -F ich /usr/share/dict/words >/root/lines
```

## Verify

```bash
cat /root/lines
```
