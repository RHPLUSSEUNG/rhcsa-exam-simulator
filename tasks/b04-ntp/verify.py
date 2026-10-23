"""Validate the explicitly configured chrony server/pool sources."""
from pathlib import Path
import shlex
import sys


def valid(text):
    sources = []
    for line in text.splitlines():
        try:
            fields = shlex.split(line, comments=True)
        except ValueError:
            return False
        if fields and fields[0] in ("server", "pool"):
            sources.append(fields)
    return (len(sources) == 1 and len(sources[0]) >= 3
            and sources[0][1] == "ntp.example.com" and "iburst" in sources[0][2:])


if __name__ == "__main__":
    sys.exit(0 if valid(Path("/etc/chrony.conf").read_text()) else 1)
