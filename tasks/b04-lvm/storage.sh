#!/usr/bin/env bash
# Solver helper: append one partition on this exam's allocated shared GPT disk.
b04_partition() {
    local disk="$1" size="$2" kind="$3" claim number start end last table part
    claim="$(cat "$RHCSA_STATE/claims/shared-b04storage.dev")" || return 1
    [[ "$(readlink -f "$disk")" == "$(readlink -f "$claim")" && -b "$disk" ]] || return 1
    [[ "$size" =~ ^[0-9]+$ && "$kind" =~ ^(lvm|swap)$ ]] || return 1
    table="$(lsblk -dn -o PTTYPE "$disk")"
    if [[ -z "$table" ]]; then
        parted -s "$disk" mklabel gpt >&2 || return 1
    elif [[ "$table" != gpt ]]; then
        echo 'Expected an allocated GPT disk' >&2; return 1
    fi
    last="$(parted -m -s "$disk" unit MiB print | awk -F: '$1 ~ /^[0-9]+$/ {gsub(/MiB/, "", $3); if ($3>last) last=$3; if ($1>n) n=$1} END {printf "%d %d", n+1, last+1}')" || return 1
    read -r number start <<<"$last"
    ((start < 1)) && start=1
    end=$((start + size))
    if [[ "$kind" == swap ]]; then
        parted -s "$disk" mkpart primary linux-swap "${start}MiB" "${end}MiB" >&2 || return 1
    else
        parted -s "$disk" mkpart primary ext4 "${start}MiB" "${end}MiB" >&2 || return 1
        parted -s "$disk" set "$number" lvm on >&2 || return 1
    fi
    partprobe "$disk" >&2 || return 1
    udevadm settle >&2 || return 1
    part="${disk}${number}"
    [[ "$disk" =~ [0-9]$ ]] && part="${disk}p${number}"
    for _ in {1..10}; do
        [[ -b "$part" ]] && break
        sleep 0.2
    done
    [[ -b "$part" ]] || return 1
    printf '%s\n' "$part"
}

# Reset visits seeded tasks in arbitrary order. Release the shared claim only
# after BOTH tasks have removed their active resources, whichever finishes last.
b04_release_if_unused() {
    local disk="$1" part
    while read -r part; do
        [[ -n "$part" ]] || continue
        if pvs --noheadings -o vg_name "$part" 2>/dev/null | grep -q '[^[:space:]]'; then
            return 0
        fi
        if swapon --show --noheadings --raw --output NAME | grep -Fxq "$part"; then
            return 0
        fi
        findmnt -rn -S "$part" >/dev/null 2>&1 && return 0
    done < <(lsblk -nrpo NAME "$disk")
    . "$RHCSA_LIB/storage-prep.sh"
    shared_cleanup b04storage
}
