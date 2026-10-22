#!/usr/bin/env bash
. "$RHCSA_LIB/storage-prep.sh"
dev="$(ensure_shared_disk b04storage)" || exit 1
echo "b04-swap: add a 400 MiB partition on $dev without destroying LVM"
exit 0
