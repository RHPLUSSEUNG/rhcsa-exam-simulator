"""Measure the ext filesystem itself, not just its containing LV."""
import re
import subprocess
import sys


def size_bytes(text):
    fields = dict(re.findall(r"^(Block count|Block size):\s*(\d+)\s*$", text, re.M))
    return int(fields.get("Block count", 0)) * int(fields.get("Block size", 0))


if __name__ == "__main__":
    result = subprocess.run(["dumpe2fs", "-h", sys.argv[1]], capture_output=True, text=True,
                            env={**__import__("os").environ, "LC_ALL": "C"})
    sys.exit(0 if result.returncode == 0 and 217 * 2**20 <= size_bytes(result.stdout) <= 243 * 2**20 else 1)
