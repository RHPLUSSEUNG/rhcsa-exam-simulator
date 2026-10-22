"""Inspect the effective automounter map dump, including its mount point."""
import re
import subprocess
import sys


def configured(text):
    for section in re.split(r"(?=Mount point:)", text):
        mount = re.search(r"Mount point:\s*(\S+)", section)
        if not mount:
            continue
        if mount[1] == "/data":
            pattern = r"(?m)^\s*public\s+.*localhost:/shares/public(?:\s|$)"
        elif mount[1] == "/data/public":
            pattern = r"(?m)^\s*/data/public\s+.*localhost:/shares/public(?:\s|$)"
        else:
            continue
        if re.search(pattern, section):
            return True
    return False


if __name__ == "__main__":
    result = subprocess.run(["automount", "-m"], capture_output=True, text=True, timeout=15)
    sys.exit(0 if result.returncode == 0 and configured(result.stdout) else 1)
