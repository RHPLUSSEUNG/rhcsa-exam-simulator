# Reference solution — Set and regenerate the GRUB menu timeout

Edit the source file and regenerate /boot/grub2/grub.cfg on RHEL 10. The blog also discusses a one-time systemd.unit=emergency.target boot argument as optional recovery practice, not as a state to leave enabled.

```bash
sed -i '/^[[:space:]]*GRUB_TIMEOUT=/d' /etc/default/grub
echo 'GRUB_TIMEOUT=10' >>/etc/default/grub
grub2-mkconfig -o /boot/grub2/grub.cfg
```

## Verify

```bash
grep GRUB_TIMEOUT /etc/default/grub
grep -E "set timeout=" /boot/grub2/grub.cfg
```
