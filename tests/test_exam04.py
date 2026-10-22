"""Read-only contracts and positive/negative fixtures for exam 04 graders."""
import importlib.util
import json
from pathlib import Path
import re
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]


def helper(task):
    spec = importlib.util.spec_from_file_location(task, ROOT / "tasks" / task / "verify.py")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


class Exam04Tests(unittest.TestCase):
    def test_paper_and_authoring_contract(self):
        rows = [line.split() for line in (ROOT / "exams/exam-r10-2node-04.2node.list").read_text().splitlines()
                if line.strip() and not line.startswith("#")]
        self.assertEqual(len(rows), 24)
        self.assertEqual(len({task for node, task in rows}), 24)
        self.assertEqual(sum(node == "node1" for node, task in rows), 14)
        self.assertEqual(sum(node == "node2" for node, task in rows), 10)
        tasks = {task for node, task in rows if task.startswith("b04-")}
        self.assertEqual(tasks, {p.name for p in (ROOT / "tasks").glob("b04-*")})
        self.assertEqual(len(tasks), 19)
        for task in tasks:
            directory = ROOT / "tasks" / task
            for name in ("meta.sh", "prompt.txt", "hint.txt", "setup.sh", "grade.sh", "teardown.sh", "solution.md"):
                self.assertTrue((directory / name).is_file(), (task, name))
            meta = (directory / "meta.sh").read_text()
            self.assertIn('TASK_RHEL="10"', meta)
            self.assertIn("TASK_CROSSNODE=1", meta)
            points = sum(map(int, re.findall(r'^ckpt(?:_expr)? "[^"\n]+" (\d+)',
                                             (directory / "grade.sh").read_text(), re.M)))
            self.assertEqual(points, int(re.search(r"TASK_POINTS=(\d+)", meta)[1]), task)
            self.assertTrue((ROOT / "tests/solvers" / (task + ".sh")).is_file())
        self.assertLess(rows.index(["node1", "b04-users"]), rows.index(["node1", "b04-cron"]))
        self.assertLess(rows.index(["node2", "b04-lvm"]), rows.index(["node2", "b04-swap"]))

    def test_new_checkpoint_translations(self):
        translations = json.loads((ROOT / "locales/ko/checkpoints.json").read_text(encoding="utf-8"))
        for path in (ROOT / "tasks").glob("b04-*/grade.sh"):
            for text in re.findall(r'^ckpt(?:_expr)? "([^"\n]+)"', path.read_text(), re.M):
                self.assertIn(text, translations, path.parent.name)
                self.assertRegex(translations[text], "[가-힣]")

    def test_sudo_effective_command_and_password_tags(self):
        sudo = helper("b04-users")
        good = "    (ALL) /usr/sbin/useradd\n    (ALL : ALL) NOPASSWD: /usr/bin/passwd, /usr/bin/dnf"
        self.assertTrue(sudo.allowed(good, "/usr/sbin/useradd"))
        self.assertTrue(sudo.allowed(good, "/usr/bin/passwd", True))
        self.assertTrue(sudo.allowed(good, "/usr/bin/dnf", True))
        self.assertFalse(sudo.allowed("# (ALL) NOPASSWD: ALL", "/usr/bin/dnf", True))
        self.assertFalse(sudo.allowed("(student) NOPASSWD: ALL", "/usr/bin/dnf", True))
        self.assertFalse(sudo.allowed("(ALL) /usr/bin/dnf", "/usr/bin/dnf", True))
        self.assertFalse(sudo.allowed("(ALL) NOPASSWD: ALL, !/usr/bin/dnf", "/usr/bin/dnf", True))
        self.assertFalse(sudo.allowed("(ALL) NOPASSWD: /usr/bin/passwd root", "/usr/bin/passwd", True))

    def test_cron_schedules_commands_and_redirection(self):
        cron = helper("b04-cron")
        self.assertTrue(cron.matches('*/2 * * * * /usr/bin/logger "EX200 in progress"', "logger"))
        self.assertTrue(cron.matches('30 12 * * * /bin/echo "Hello World" >>/home/natasha/hello.log', "greeting"))
        self.assertTrue(cron.matches('45 00 * * * find /tmp -type f -empty -delete', "cleanup"))
        for text, kind in (
            ('# */2 * * * * logger "EX200 in progress"', "logger"),
            ('*/3 * * * * logger "EX200 in progress"', "logger"),
            ('*/2 * * * * echo logger "EX200 in progress"', "logger"),
            ('30 12 * * * echo "Hello World" >/home/natasha/hello.log', "greeting"),
            ('45 12 * * * find /tmp -type f -empty -delete', "cleanup"),
            ('45 0 * * * find /tmp -type d -empty -delete', "cleanup"),
            ('45 0 * * * find /tmp -type f -o -empty -delete', "cleanup"),
        ):
            self.assertFalse(cron.matches(text, kind), text)

    def test_acl_masks_and_defaults(self):
        acl = helper("b04-acl")
        good = "user::rw-\nuser:natasha:rw-\nuser:harry:---\ngroup::r--\nmask::rw-\nother::r--\n"
        self.assertTrue(acl.valid(good))
        self.assertFalse(acl.valid(good.replace("mask::rw-", "mask::r--")))
        self.assertFalse(acl.valid(good.replace("user:harry:---", "user:harry:r--")))
        finance = "group:finance:r-x\nmask::r-x\ndefault:group:finance:r-x\ndefault:mask::rwx\n"
        self.assertTrue(acl.valid(finance, True))
        self.assertFalse(acl.valid(finance.replace("default:mask::rwx", "default:mask::r--"), True))
        self.assertFalse(acl.valid(finance.split("default:")[0], True))

    def test_automount_map_must_match_mount_and_source(self):
        autofs = helper("b04-autofs")
        good = "Mount point: /data\nsource(s):\n  map: /etc/auto.data\n  public | -rw localhost:/shares/public\n"
        self.assertTrue(autofs.configured(good))
        self.assertFalse(autofs.configured(good.replace("/data", "/wrong")))
        self.assertFalse(autofs.configured(good.replace("localhost:", "other:")))
        self.assertFalse(autofs.configured("Mount point: /data\nMount point: /wrong\npublic | localhost:/shares/public"))

    def test_ext_filesystem_size_is_not_lv_size(self):
        resize = helper("b04-resize")
        self.assertEqual(resize.size_bytes("Block count: 58880\nBlock size: 4096\n"), 230 * 2**20)
        self.assertEqual(resize.size_bytes("Block count: 51200\nBlock size: 4096\n"), 200 * 2**20)
        self.assertEqual(resize.size_bytes("Block count: 58880\n"), 0)

    def test_swap_partition_size_and_persistence_identity(self):
        swap = helper("b04-swap")
        nodes = [{"name": "/dev/vdb", "type": "disk", "size": 2**30, "children": [
            {"name": "/dev/vdb1", "type": "part", "size": 480 * 2**20},
            {"name": "/dev/vdb2", "type": "part", "size": 400 * 2**20}]}]
        self.assertEqual(list(swap.partitions(nodes)), ["/dev/vdb2"])
        resolver = lambda value: {"UUID=new": "/dev/vdb2", "UUID=old": "/dev/vda2"}.get(value, value)
        self.assertTrue(swap.persistent("UUID=new none swap defaults 0 0", {"/dev/vdb2"}, resolver))
        self.assertFalse(swap.persistent("UUID=old none swap defaults 0 0", {"/dev/vdb2"}, resolver))
        self.assertFalse(swap.persistent("# UUID=new none swap defaults 0 0", {"/dev/vdb2"}, resolver))
        self.assertFalse(swap.persistent("UUID=new /mnt/data ext4 defaults 0 0", {"/dev/vdb2"}, resolver))

    def test_timer_service_and_actual_script_commands(self):
        timer = helper("b04-notify")
        good = "Type=oneshot\nRemainAfterExit=no\nExecStart={ path=/usr/local/bin/notify.sh ; argv[]=/usr/local/bin/notify.sh ; }"
        self.assertTrue(timer.service_ok(good, "/usr/local/bin/notify.sh"))
        self.assertFalse(timer.service_ok(good.replace("oneshot", "simple"), "/usr/local/bin/notify.sh"))
        self.assertFalse(timer.service_ok(good.replace("RemainAfterExit=no", "RemainAfterExit=yes"), "/usr/local/bin/notify.sh"))
        self.assertFalse(timer.service_ok(good, "/usr/local/bin/system-check.sh"))
        self.assertTrue(timer.logger_command('#!/bin/bash\nlogger "Time for Break!"'))
        self.assertFalse(timer.logger_command('# logger "Time for Break!"'))
        self.assertFalse(timer.logger_command('echo logger "Time for Break!"'))
        self.assertTrue(timer.append_command("date >> /var/log/system-check.log"))
        self.assertFalse(timer.append_command("date > /var/log/system-check.log"))
        self.assertFalse(timer.append_command("date >> /usr/local/bin/system-check.log"))

    def test_timer_schedule_and_target(self):
        timer = helper("b04-notify")
        text = "Unit=notify.service\nTimersMonotonic=\nTimersCalendar={ OnCalendar=*-*-* 07:00:00 ; next_elapse=Thu 2026-10-22 07:00:00 KST }"
        with patch.object(timer, "run", return_value=text), patch.object(timer, "canonical", side_effect=lambda x: x):
            self.assertTrue(timer.timer_ok("notify.timer", "*-*-* 07:00:00"))
            self.assertFalse(timer.timer_ok("notify.timer", "*-*-* 08:00:00"))
            self.assertFalse(timer.timer_ok("system-check.timer", "*-*-* 07:00:00"))
        text = "Unit=system-check.service\nTimersCalendar=\nTimersMonotonic={ OnUnitActiveUSec=1min ; next_elapse=1h }"
        with patch.object(timer, "run", return_value=text):
            self.assertTrue(timer.timer_ok("system-check.timer", "*-*-* *:*:00"))
        with patch.object(timer, "run", return_value=text.replace("1min", "2min")):
            self.assertFalse(timer.timer_ok("system-check.timer", "*-*-* *:*:00"))


if __name__ == "__main__":
    unittest.main()
