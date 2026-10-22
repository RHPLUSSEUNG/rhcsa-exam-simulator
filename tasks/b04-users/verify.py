"""Check the effective sudo policy, rather than a particular sudoers filename."""
import os
import re
import subprocess
import sys


def allowed(listing, command, nopass=False):
    result = False
    for line in listing.splitlines():
        match = re.match(r"\s*\(([^)]+)\)\s*(.*)", line)
        if not match or not ({"root", "ALL"} & set(re.split(r"[,:\s]+", match[1]))):
            continue
        passwordless = False
        for entry in match[2].split(","):
            entry = entry.strip()
            while re.match(r"^[A-Z_]+:", entry):
                tag, entry = entry.split(":", 1)
                if tag in ("PASSWD", "NOPASSWD"):
                    passwordless = tag == "NOPASSWD"
                entry = entry.strip()
            deny = entry.startswith("!")
            path, _, arguments = entry.lstrip("!").partition(" ")
            if (path == "ALL" or os.path.realpath(path) == os.path.realpath(command)) and arguments.strip() in ("", "*"):
                result = not deny and (passwordless or not nopass)
    return result


if __name__ == "__main__":
    policy = subprocess.run(["sudo", "-l", "-U", sys.argv[2]],
                            env=dict(os.environ, LC_ALL="C"), capture_output=True, text=True)
    sys.exit(0 if policy.returncode == 0 and allowed(
        policy.stdout, sys.argv[3], len(sys.argv) > 4) else 1)
