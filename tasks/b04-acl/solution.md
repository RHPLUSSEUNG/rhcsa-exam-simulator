# Reference solution — Configure named and inheritable ACL entries

Named-user entries override the other class. Check the ACL mask as well as the entry itself. Default ACLs inherit through the creation mode: they do not make a 0666 file executable.

```bash
cp /etc/fstab /var/tmp/fstab
chown root:root /var/tmp/fstab
chmod 0644 /var/tmp/fstab
setfacl -m u:natasha:rw-,u:harry:---,o::r-- /var/tmp/fstab
setfacl -m g:finance:r-x /groups/accounting
setfacl -m d:g:finance:r-x /groups/accounting
```

## Verify

```bash
getfacl -p /var/tmp/fstab /groups/accounting
```
