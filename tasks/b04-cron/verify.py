"""Validate active crontab entries and their commands without running jobs."""
import re
import shlex
import subprocess
import sys
from pathlib import Path


def jobs(text):
    for line in text.splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        fields = line.split(None, 5)
        if len(fields) == 6 and re.match(r"^[\d*/,-]+$", fields[0]):
            try:
                lexer = shlex.shlex(fields[5], posix=True, punctuation_chars=";&|<>")
                lexer.whitespace_split = True
                schedule = [str(int(x)) if x.isdigit() else x for x in fields[:5]]
                yield schedule, list(lexer)
            except ValueError:
                continue


def matches(text, kind):
    for schedule, tokens in jobs(text):
        if not tokens:
            continue
        command = Path(tokens[0]).name
        if kind == "logger":
            minutes = schedule[0]
            every_two = minutes == "*/2" or minutes == ",".join(map(str, range(0, 60, 2)))
            if every_two and schedule[1:] == ["*", "*", "*", "*"] and command == "logger":
                if tokens[1:] == ["EX200 in progress"]:
                    return True
        if kind == "greeting" and schedule == ["30", "12", "*", "*", "*"]:
            if command == "echo" and tokens[1:] == ["Hello World", ">>", "/home/natasha/hello.log"]:
                return True
        if kind == "cleanup" and schedule == ["45", "0", "*", "*", "*"]:
            if command == "find" and tokens[1:2] == ["/tmp"]:
                rest = tokens[2:]
                if "-type" in rest and "-empty" in rest and "-delete" in rest:
                    at = rest.index("-type")
                    if rest[at + 1:at + 2] == ["f"] and not any(x in rest for x in ("-o", "-or", "!", "-not")):
                        return True
    return False


if __name__ == "__main__":
    mode = sys.argv[1]
    if mode == "allow":
        path = Path("/etc/cron.allow")
        ok = path.is_file() and {x.strip() for x in path.read_text().splitlines()
                                if x.strip() and not x.lstrip().startswith("#")} == {"tom"}
    else:
        user = "root" if mode == "cleanup" else "natasha"
        result = subprocess.run(["crontab", "-l", "-u", user], capture_output=True, text=True)
        ok = result.returncode == 0 and matches(result.stdout, mode)
    sys.exit(0 if ok else 1)
