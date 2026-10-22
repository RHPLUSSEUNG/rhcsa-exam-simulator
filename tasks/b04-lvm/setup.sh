#!/usr/bin/env bash
. "$RHCSA_LIB/storage-prep.sh"
dev="$(ensure_shared_disk b04storage)" || exit 1
echo "b04-lvm: shared blank storage disk is $dev; keep room for swap"
exit 0
