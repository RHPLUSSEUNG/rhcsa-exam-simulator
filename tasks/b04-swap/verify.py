"""Require new swap on the allocated disk, and the same swap in fstab."""
import json
import os
from pathlib import Path
import subprocess
import sys


def partitions(nodes):
    for node in nodes:
        if node.get("type") == "part" and int(node.get("size", 0)) == 400 * 2**20:
            yield node["name"]
        yield from partitions(node.get("children", []))


def persistent(text, active, resolve):
    for line in text.splitlines():
        fields = line.split()
        if len(fields) >= 3 and not fields[0].startswith("#") and fields[2] == "swap":
            if resolve(fields[0]) in active:
                return True
    return False


def run(*args):
    return subprocess.check_output(args, text=True).strip()


def resolve(spec):
    try:
        return os.path.realpath(run("findfs", spec) if "=" in spec else spec)
    except subprocess.CalledProcessError:
        return ""


if __name__ == "__main__":
    state = Path(os.environ.get("RHCSA_STATE", "/var/lib/rhcsa-sim"))
    disk = (state / "claims/shared-b04storage.dev").read_text().strip()
    tree = json.loads(run("lsblk", "-b", "-J", "-p", "-o", "NAME,TYPE,SIZE", disk))
    candidates = {os.path.realpath(x) for x in partitions(tree["blockdevices"])}
    active = candidates & {os.path.realpath(x) for x in run(
        "swapon", "--show=NAME", "--noheadings", "--raw").splitlines()}
    ok = bool(active)
    if sys.argv[1] == "persistent":
        ok = ok and persistent(Path("/etc/fstab").read_text(), active, resolve)
    sys.exit(0 if ok else 1)
