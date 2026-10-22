#!/usr/bin/env bash
cp /etc/fstab /var/tmp/fstab
chown root:root /var/tmp/fstab
chmod 0644 /var/tmp/fstab
setfacl -m u:natasha:rw-,u:harry:---,o::r-- /var/tmp/fstab
setfacl -m g:finance:r-x /groups/accounting
setfacl -m d:g:finance:r-x /groups/accounting
