"""Check effective systemd properties and observable script effects."""
import os
from pathlib import Path
import re
import shlex
import subprocess
import sys
import time


def run(*args):
    return subprocess.check_output(args, text=True, timeout=15,
                                   env=dict(os.environ, LC_ALL="C")).strip()


def commands(text):
    for line in text.splitlines():
        try:
            tokens = shlex.split(line, comments=True)
        except ValueError:
            continue
        if tokens:
            yield tokens


def logger_command(text):
    return any(Path(t[0]).name == "logger" and t[1:] == ["Time for Break!"] for t in commands(text))


def append_command(text):
    return any(Path(t[0]).name == "date" and ">>" in t
               and t[t.index(">>") + 1:] == ["/var/log/system-check.log"] for t in commands(text))


def properties(text):
    return dict(line.split("=", 1) for line in text.splitlines() if "=" in line)


def service_ok(text, script):
    values = properties(text)
    return values.get("Type") == "oneshot" and values.get("RemainAfterExit") == "no" and bool(re.search(
        r"(?:path=|argv\[\]=|\s)" + re.escape(script) + r"(?:\s|[;}])", values.get("ExecStart", "")))


def calendar_expressions(text):
    return re.findall(r"OnCalendar=(.*?)\s*;\s*next_elapse=", text)


def canonical(expression):
    text = run("systemd-analyze", "calendar", expression)
    match = re.search(r"Normalized form:\s*(.+)", text)
    return match[1].strip() if match else ""


def timer_ok(name, expected):
    # The manager's parsed properties reflect the loaded configuration.
    values = properties(run("systemctl", "show", name, "-p", "TimersCalendar", "-p", "TimersMonotonic", "-p", "Unit"))
    if values.get("Unit") != name.replace(".timer", ".service"):
        return False
    expressions = calendar_expressions(values.get("TimersCalendar", ""))
    monotonic = values.get("TimersMonotonic", "")
    if expressions:
        return not monotonic and all(canonical(x) == expected for x in expressions)
    if expected == "*-*-* *:*:00":
        intervals = re.findall(r"(On\w+USec)=([^;]+);", monotonic)
        return (any(key == "OnUnitActiveUSec" and value.strip() in ("1min", "60s") for key, value in intervals)
                and all(key in ("OnUnitActiveUSec", "OnBootUSec", "OnActiveUSec") for key, value in intervals))
    return False


def main(mode):
    if mode in ("service", "check-service"):
        name = "notify" if mode == "service" else "system-check"
        return service_ok(run("systemctl", "show", name + ".service", "-p", "Type", "-p", "ExecStart", "-p", "RemainAfterExit"),
                          "/usr/local/bin/" + name + ".sh")
    if mode in ("daily", "minute"):
        return timer_ok("notify.timer" if mode == "daily" else "system-check.timer",
                        "*-*-* 07:00:00" if mode == "daily" else "*-*-* *:*:00")
    script = Path("/usr/local/bin/notify.sh" if mode == "script" else "/usr/local/bin/system-check.sh")
    if not script.is_file() or not os.access(script, os.X_OK):
        return False
    text = script.read_text()
    if mode == "script":
        if not logger_command(text):
            return False
        since = str(int(time.time()) - 1)
        subprocess.run([str(script)], check=True, timeout=10)
        return "Time for Break!" in run("journalctl", "--since", "@" + since, "--no-pager", "-o", "cat").splitlines()
    if not append_command(text):
        return False
    log = Path("/var/log/system-check.log")
    before = log.read_bytes() if log.exists() else b""
    subprocess.run([str(script)], check=True, timeout=10)
    after = log.read_bytes()
    return after.startswith(before) and len(after) > len(before)


if __name__ == "__main__":
    try:
        ok = main(sys.argv[1])
    except (OSError, ValueError, subprocess.SubprocessError):
        ok = False
    sys.exit(0 if ok else 1)
