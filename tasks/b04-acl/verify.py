"""Check ACL permissions after applying the access/default mask."""
import subprocess
import sys


def entries(text):
    result = {}
    for line in text.splitlines():
        line = line.split("#", 1)[0].strip()
        parts = line.split(":")
        if len(parts) >= 3:
            result[":".join(parts[:-1])] = set(parts[-1]) - {"-"}
    return result


def effective(acl, name, default=False):
    prefix = "default:" if default else ""
    return acl.get(prefix + name, set()) & acl.get(prefix + "mask:", set("rwx"))


def valid(text, finance=False):
    acl = entries(text)
    if finance:
        return all(effective(acl, "group:finance", default) == set("rx") for default in (False, True))
    return (effective(acl, "user:natasha") == set("rw")
            and "user:harry" in acl and not effective(acl, "user:harry")
            and acl.get("other:") == {"r"})


if __name__ == "__main__":
    finance = len(sys.argv) > 1 and sys.argv[1] == "finance"
    target = "/groups/accounting" if finance else "/var/tmp/fstab"
    result = subprocess.run(["getfacl", "-cp", target], capture_output=True, text=True)
    sys.exit(0 if result.returncode == 0 and valid(result.stdout, finance) else 1)
