"""Read-only localization tests; no RHEL configuration commands are executed."""
import contextlib
import importlib.util
import io
import json
import os
from pathlib import Path
import re
import sys
import tempfile
import unittest
from unittest.mock import patch
from types import SimpleNamespace

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'lib'))
import i18n


def module(name, path):
    spec = importlib.util.spec_from_file_location(name, ROOT / path)
    result = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(result)
    return result


class LocalizationTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.data = i18n.catalog('tasks', 'ko')
        cls.web = module('exam_web', 'tui/exam_web.py')
        cls.report = module('report', 'report/report.py')

    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.state = Path(self.temp.name)
        self.addCleanup(self.temp.cleanup)
        self.old_env = dict(os.environ)
        self.addCleanup(lambda: (os.environ.clear(), os.environ.update(self.old_env)))
        os.environ.pop('RHCSA_LANG', None)
        os.environ['RHCSA_RHEL'] = '9'

    def test_all_tasks_and_exam_references_have_translations(self):
        tasks = {p.name for p in (ROOT / 'tasks').iterdir() if p.is_dir()}
        self.assertEqual(tasks, set(self.data))
        for tid, e in self.data.items():
            for field in ('title', 'prompt', 'solution', 'hint'):
                self.assertRegex(e[field], '[가-힣]', (tid, field))
                self.assertNotIn('[번역 필요]', e[field])
        for paper in (ROOT / 'exams').glob('*.list'):
            for line in paper.read_text(encoding='utf-8').splitlines():
                cols = line.split('#', 1)[0].split()
                if cols:
                    self.assertIn(cols[1] if cols[0] in ('node1', 'node2') else cols[0], self.data)

    def test_code_blocks_are_byte_identical(self):
        for tid, e in self.data.items():
            original = (ROOT / 'tasks' / tid / 'solution.md').read_text(encoding='utf-8')
            self.assertEqual(re.findall(r'```.*?```', original, re.S),
                             re.findall(r'```.*?```', e['solution'], re.S), tid)

    def test_prompt_placeholders_numbers_paths_and_literals(self):
        failures = []
        for tid, e in self.data.items():
            original = (ROOT / 'tasks' / tid / 'prompt.txt').read_text(encoding='utf-8')
            for pattern in (r'\{\{\w+\}\}', r'(?<![A-Za-z0-9])\d+(?:\.\d+)*(?![A-Za-z0-9])', r'`[^`]+`',
                            r'(?<![A-Za-z0-9])(?:file://|https?://)?/[A-Za-z0-9_{}.$<>/-]+'):
                before = {v.rstrip('.') for v in re.findall(pattern, original)}
                after = {v.rstrip('.') for v in re.findall(pattern, e['prompt'])}
                if not before <= after:
                    failures.append((tid, before - after))
        self.assertEqual(failures, [], str(failures))

    def test_default_precedence_and_fallback(self):
        self.assertEqual(i18n.language(self.state), 'ko')
        i18n.save_language(self.state, 'en')
        self.assertEqual(i18n.language(self.state), 'en')
        os.environ['RHCSA_LANG'] = 'ko'
        self.assertEqual(i18n.language(self.state), 'ko')
        self.assertEqual(i18n.language(self.state, 'en'), 'en')
        self.assertEqual(i18n.title('unknown', 'original', 'ko'), 'original')
        self.assertEqual(i18n.title('acl-default', 'original', 'en'), 'original')

    def test_switch_preserves_session_values_and_scores(self):
        (self.state / 'params').mkdir()
        (self.state / 'params/acl-default.env').write_text('DIR=sharedx234\nG=developers\n')
        session = {'exam': 'exam-01', 'start': 100, 'duration': 9000, 'tasks': ['acl-default']}
        path = self.state / 'session.json'
        path.write_text(json.dumps(session))
        results = self.state / 'results'; results.mkdir()
        result = results / 'acl-default.jsonl'
        result.write_text(json.dumps({'ok': True, 'points': 10, 'max': 10, 'checkpoint': 'example'}) + '\n')
        originals = {p: p.read_bytes() for p in (path, result, self.state / 'params/acl-default.env')}
        before = self.report.grade(path, ROOT / 'tasks', results, 70)
        ko = i18n.task_text(ROOT / 'tasks', 'acl-default', 'prompt', self.state, 'ko')
        en = i18n.task_text(ROOT / 'tasks', 'acl-default', 'prompt', self.state, 'en')
        for text in (ko, en):
            self.assertIn('/sharedx234', text); self.assertIn('developers', text)
            self.assertNotIn('{{', text)
        i18n.save_language(self.state, 'en'); i18n.save_language(self.state, 'ko')
        after = self.report.grade(path, ROOT / 'tasks', results, 70)
        before.pop('graded_at'); after.pop('graded_at')
        self.assertEqual(before, after)
        for p, original in originals.items(): self.assertEqual(p.read_bytes(), original)

    def test_controller_rendered_parameters(self):
        (self.state / 'prompts').mkdir()
        original = (ROOT / 'tasks/acl-default/prompt.txt').read_text(encoding='utf-8')
        (self.state / 'prompts/acl-default.txt').write_text(
            original.replace('{{DIR}}', 'remote42').replace('{{G}}', 'sysmgrs'), encoding='utf-8')
        text = i18n.task_text(ROOT / 'tasks', 'acl-default', 'prompt', self.state, 'ko')
        self.assertIn('/remote42', text); self.assertIn('sysmgrs', text)
        self.assertNotIn('{{', text)
        solution = i18n.task_text(ROOT / 'tasks', 'acl-default', 'solution', self.state, 'ko')
        self.assertIn('/remote42', solution); self.assertIn('sysmgrs', solution)
        self.assertNotIn('<DIR>', solution)

    def test_display_width(self):
        self.assertEqual(i18n.clip('한글abc', 5), '한글a')
        self.assertEqual(i18n.clip('가', 1), '')
        for width in (2, 5, 10, 40):
            for line in i18n.wrap('한글 테스트 e\u0301 long-line\n\n다음 행', width):
                self.assertLessEqual(sum(i18n.cell_width(c) for c in line), width)

    def test_checkpoint_templates_preserve_runtime_values(self):
        self.assertEqual(i18n.checkpoint('volume group directory exists', 'ko'),
                         '볼륨 그룹 directory 존재')
        self.assertEqual(i18n.checkpoint('volume group directory exists', 'en'),
                         'volume group directory exists')
        self.assertEqual(i18n.checkpoint('unknown new checkpoint', 'ko'), 'unknown new checkpoint')
        for en, ko in i18n.catalog('checkpoints', 'ko').items():
            token = r'\$\{[^}]+\}|\$[A-Za-z_]\w*|\{\{\w+\}\}'
            self.assertEqual(set(re.findall(token, en)), set(re.findall(token, ko)), en)

    def test_metadata_and_scoring_report_json_stays_canonical(self):
        session = self.state / 'session.json'
        session.write_text(json.dumps({'exam':'exam-01', 'start':100, 'duration':9000, 'tasks':['acl-default']}))
        results = self.state/'results'; results.mkdir()
        (results/'acl-default.jsonl').write_text(json.dumps({'ok':True,'points':8,'max':8,
            'checkpoint':'default ACL grants group developers rwx'})+'\n')
        os.environ['RHCSA_LANG'] = 'ko'
        report = self.report.grade(session, ROOT/'tasks', results, 70)
        before = json.dumps(report, sort_keys=True)
        self.report.write_outputs(report, self.state/'reports')
        self.report.write_html(report, self.state/'reports', 'test')
        self.assertEqual(json.dumps(report, sort_keys=True), before)
        written = json.loads(next((self.state/'reports').glob('*.json')).read_text())
        self.assertEqual(written['rows'][0]['title'], 'Set a default ACL on a directory')
        self.assertEqual(written['score300'], 300)

    def test_browser_switch_and_command_protection(self):
        session = {'exam': 'exam-01', 'start': 100, 'duration': 9000, 'tasks': ['acl-default']}
        (self.state / 'session.json').write_text(json.dumps(session))
        self.web.ARGS = SimpleNamespace(state=str(self.state), tasks=str(ROOT / 'tasks'),
                                       session=str(self.state / 'session.json'),
                                       prompts=str(self.state / 'prompts'), hints='', solutions='', lang='ko')
        ko = self.web.exam_page()
        self.assertIn('lang="ko"', ko); self.assertIn('/api/language', ko)
        self.assertIn('언어 선택', ko)
        self.assertIn('value="ko" selected', ko)
        self.assertIn('기본(DEFAULT) ACL', self.web.task_page('acl-default'))
        vm = self.web.vm_page()
        self.assertIn("a=='Rebuild'", vm)
        self.assertIn('재구성', vm)
        self.web.ARGS.lang = 'en'
        en = self.web.exam_page()
        self.assertIn('lang="en"', en); self.assertIn('Select Language', en)
        code = '<pre>echo "Reference solution:"</pre><code>Start</code>'
        self.assertIn(code, i18n.html_display(code, 'ko'))

    def test_release_override_uses_english_fallback(self):
        tasks = self.state / 'tasks'; (tasks / 'acl-default').mkdir(parents=True)
        (tasks / 'acl-default/prompt.rhel10.txt').write_text('Version 10 original\n')
        os.environ['RHCSA_RHEL'] = '10'
        self.assertEqual(i18n.task_text(tasks, 'acl-default', 'prompt', lang='ko'), 'Version 10 original\n')

    def test_http_language_switch_keeps_session_and_marks(self):
        import threading, urllib.request, urllib.error
        session = self.state / 'session.json'
        session.write_text(json.dumps({'exam':'exam-01', 'start':100, 'duration':9000, 'tasks':['acl-default']}))
        marks = self.state / 'marks.json'; marks.write_text('{"acl-default":"done"}')
        before = session.read_bytes(), marks.read_bytes()
        self.web.ARGS = SimpleNamespace(session=str(session), state=str(self.state),
            tasks=str(ROOT/'tasks'), prompts='', hints='', solutions='', lang='ko')
        server = self.web.ThreadingHTTPServer(('127.0.0.1', 0), self.web.H)
        thread = threading.Thread(target=server.serve_forever, daemon=True); thread.start()
        try:
            base = 'http://127.0.0.1:' + str(server.server_port)
            request = urllib.request.Request(base+'/api/language', data=b'lang=en', method='POST')
            with urllib.request.urlopen(request) as response: self.assertEqual(response.status, 200)
            self.assertEqual(i18n.language(self.state), 'en')
            with urllib.request.urlopen(base+'/') as response:
                self.assertIn('lang="en"', response.read().decode('utf-8'))
            request = urllib.request.Request(base+'/api/language', data=b'lang=invalid', method='POST')
            with self.assertRaises(urllib.error.HTTPError): urllib.request.urlopen(request)
            self.assertEqual(before, (session.read_bytes(), marks.read_bytes()))
        finally:
            server.shutdown(); server.server_close(); thread.join()

    def test_headless_tui_resize_selection_and_language(self):
        fake = SimpleNamespace(error=RuntimeError, curs_set=lambda *a: None, has_colors=lambda: False,
            color_pair=lambda *a: 0, A_BOLD=1, A_DIM=2, A_NORMAL=0, ACS_VLINE='|',
            KEY_DOWN=258, KEY_UP=259, KEY_NPAGE=338, KEY_PPAGE=339)
        with patch.dict(sys.modules, {'curses': fake}):
            tui = module('exam_tui_test', 'tui/exam_tui.py')
        session = self.state / 'session.json'
        ids = list(self.data)[:12]
        session.write_text(json.dumps({'exam':'exam-01', 'start':100, 'duration':9000, 'tasks':ids}))
        class Screen:
            def __init__(self, size, keys): self.size=size; self.keys=iter(keys); self.calls=[]
            def getmaxyx(self): return self.size
            def getch(self): return next(self.keys, ord('q'))
            def addstr(self, y, x, text, attr):
                assert sum(i18n.cell_width(c) for c in text) <= self.size[1] - x - 1
                self.calls.append(text)
            def addch(self, *a): pass
            def __getattr__(self, name): return lambda *a: None
        ex = tui.Exam(str(session), str(ROOT/'tasks'), state_dir=str(self.state))
        ex.marked[0] = True
        before = session.read_bytes()
        screen = Screen((8, 60), [ord('l')] + [fake.KEY_DOWN]*11 + [ord('q')])
        tui.draw(screen, ex)
        self.assertEqual(ex.lang, 'en'); self.assertTrue(ex.marked[0])
        self.assertEqual(session.read_bytes(), before)
        self.assertTrue(any('12/12' in s for s in screen.calls))
        tui.draw(Screen((4, 20), [ord('q')]), ex)


if __name__ == '__main__':
    unittest.main()
