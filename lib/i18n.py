"""Display-only localization. English task files and session data are canonical."""
import argparse
import json
import os
from pathlib import Path
import re
import sys
import unicodedata
from functools import lru_cache

ROOT = Path(__file__).resolve().parents[1]
LANGUAGE_NAMES = {'ko': '한국어', 'en': 'English'}
LANGUAGES = tuple(LANGUAGE_NAMES)


def language(state=None, explicit=None):
    if explicit in LANGUAGES:
        return explicit
    env = os.environ.get('RHCSA_LANG')
    if env in LANGUAGES:
        return env
    try:
        saved = (Path(state or os.environ.get('RHCSA_STATE', '/var/lib/rhcsa-sim')) / 'language').read_text().strip()
        if saved in LANGUAGES:
            return saved
    except OSError:
        pass
    return 'ko'


def save_language(state, lang):
    if lang not in LANGUAGES:
        raise ValueError('지원 언어 / supported languages: ' + ', '.join(LANGUAGES))
    path = Path(state) / 'language'
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(lang + '\n', encoding='utf-8')


def catalog(name, lang=None):
    return _load_catalog(name, lang or language())


@lru_cache(maxsize=16)
def _load_catalog(name, lang):
    if lang == 'en':
        return {}
    try:
        return json.loads((ROOT / 'locales' / lang / (name + '.json')).read_text(encoding='utf-8'))
    except (OSError, ValueError):
        return {}


def title(tid, original, lang=None):
    return catalog('tasks', lang).get(tid, {}).get('title') or original


@lru_cache(maxsize=4)
def title_pairs(lang):
    pairs = []
    for tid, entry in catalog('tasks', lang).items():
        try:
            text = (ROOT / 'tasks' / tid / 'meta.sh').read_text(encoding='utf-8')
            match = re.search(r'^TASK_TITLE="(.*)"', text, re.M)
            if match and entry.get('title'):
                pairs.append((match[1], entry['title']))
        except OSError:
            pass
    return tuple(pairs)


def params(state, tid):
    values = {}
    try:
        for line in (Path(state) / 'params' / (tid + '.env')).read_text(encoding='utf-8').splitlines():
            if '=' in line and not line.startswith('#'):
                k, v = line.split('=', 1)
                values[k] = v.strip().strip('"')
    except OSError:
        pass
    return values


def substitute(text, values, solution=False):
    text = re.sub(r'\{\{(\w+)\}\}', lambda m: values.get(m[1], m[0]), text)
    if solution:
        text = re.sub(r'<([A-Z][A-Z0-9_]*)>', lambda m: values.get(m[1], m[0]), text)
    return text


def recovered_values(original, rendered):
    tokens = re.split(r'(\{\{\w+\}\})', original.rstrip())
    names = [p[2:-2] for p in tokens if re.fullmatch(r'\{\{\w+\}\}', p)]
    pattern = ''.join('(.*?)' if re.fullmatch(r'\{\{\w+\}\}', p) else re.escape(p) for p in tokens)
    match = re.fullmatch(pattern, rendered.rstrip(), re.S)
    return dict(zip(names, match.groups())) if match else {}


def task_text(tasks, tid, kind, state=None, lang=None):
    lang = lang or language(state)
    directory = Path(tasks) / tid
    suffix = '.md' if kind == 'solution' else '.txt'
    release = os.environ.get('RHCSA_RHEL', '9')
    src = directory / (kind + '.rhel' + release + suffix)
    if not src.is_file():
        src = directory / (kind + suffix)
    entry = catalog('tasks', lang).get(tid, {})
    # Version overrides must not silently use a translation of another version.
    key = kind if src.name == kind + suffix else src.stem
    original = src.read_text(encoding='utf-8') if src.is_file() else ''
    if lang == 'en' and state:
        try:
            folder = {'prompt': 'prompts', 'hint': 'hints', 'solution': 'solutions'}[kind]
            return (Path(state) / folder / (tid + '.txt')).read_text(encoding='utf-8')
        except OSError:
            pass
    if kind == 'hint' and not original:
        if entry.get('hint'):
            return substitute(entry['hint'], params(state, tid) if state else {})
        # Preserve the existing command-harvesting hint generator; its rendered
        # English output is localized using the curated message catalog.
        try:
            original = (Path(state) / 'hints' / (tid + '.txt')).read_text(encoding='utf-8')
        except (OSError, TypeError):
            return ''
        return display(original, state, lang)
    text = entry.get(key) or original
    values = params(state, tid) if state else {}
    if state and kind != 'prompt':
        prompt_src = directory / ('prompt.rhel' + release + '.txt')
        if not prompt_src.is_file():
            prompt_src = directory / 'prompt.txt'
        try:
            source_prompt = prompt_src.read_text(encoding='utf-8')
            live_prompt = (Path(state) / 'prompts' / (tid + '.txt')).read_text(encoding='utf-8')
            values.update(recovered_values(source_prompt, live_prompt))
        except OSError:
            pass
    rendered = substitute(text, values, kind == 'solution')
    # Controller paper includes node2 tasks whose parameters live on node2.
    # Recover the substitution values from the canonical fetched prompt without
    # regenerating them or mutating either node's state.
    if kind == 'prompt' and state:
        try:
            live = (Path(state) / 'prompts' / (tid + '.txt')).read_text(encoding='utf-8')
            recovered = recovered_values(original, live)
            if recovered or live.rstrip() == original.rstrip():
                values.update(recovered)
                rendered = substitute(text, values)
            elif live != substitute(original, values):
                # Troubleshooting prompts can contain extra fault instructions.
                canonical = substitute(original, values)
                rendered = live.replace(canonical.rstrip(), rendered.rstrip(), 1)
        except OSError:
            pass
    return rendered


def display(text, state=None, lang=None):
    """Translate presentation strings only, retaining captured values verbatim."""
    lang = lang or language(state)
    if lang == 'en':
        return text
    text = re.sub(r'^(\s*(?:OK|XX|✓|✗)\s+)(.*?)(\s+\d+/\d+.*)$',
                  lambda m: m[1] + checkpoint(m[2].rstrip(), lang) + m[3], text, flags=re.M)
    messages = catalog('messages', lang)
    if text.strip() in messages:
        return text.replace(text.strip(), messages[text.strip()], 1)
    for en, ko in sorted(messages.items(), key=lambda p: -len(p[0])):
        if len(en) >= 10 or en.endswith(':'):
            text = text.replace(en, ko)
    for en, ko in title_pairs(lang):
        text = text.replace(en, ko)
    for pattern, replacement in catalog('patterns', lang).items():
        text = re.sub(pattern, replacement, text)
    return text


@lru_cache(maxsize=4)
def checkpoint_patterns(lang):
    token = r'(\$\{[^}]+\}|\$[A-Za-z_]\w*|\{\{\w+\}\})'
    result = []
    entries = catalog('checkpoints', lang).items()
    for en, ko in sorted(entries, key=lambda p: -len(re.sub(token, '', p[0]))):
        parts = re.split(token, en)
        names = parts[1::2]
        pattern = ''.join('(.*?)' if i % 2 else re.escape(p) for i, p in enumerate(parts))
        result.append((re.compile(pattern), names, ko))
    return tuple(result)


def checkpoint(text, lang=None):
    lang = lang or language()
    if lang == 'en':
        return text
    for pattern, names, translation in checkpoint_patterns(lang):
        match = pattern.fullmatch(text)
        if match:
            values = dict(zip(names, match.groups()))
            return re.sub(r'\$\{[^}]+\}|\$[A-Za-z_]\w*|\{\{\w+\}\}',
                          lambda m: values.get(m[0], m[0]), translation)
    return text


def print_display(*args, **kwargs):
    import builtins
    sep = kwargs.pop('sep', ' ')
    builtins.print(display(sep.join(map(str, args))), **kwargs)


def html_display(text, lang=None):
    """Localize text nodes, preserving markup, script actions and command blocks."""
    from html.parser import HTMLParser
    import html
    lang = lang or language()
    if lang == 'en':
        return text.replace('<html>', '<html lang="en">', 1)
    messages = catalog('messages', lang)
    class Translator(HTMLParser):
        def __init__(self):
            super().__init__(convert_charrefs=False)
            self.out = []; self.protected = []
        def handle_starttag(self, tag, attrs):
            if tag in ('pre', 'code', 'script', 'style'):
                self.protected.append(tag)
            self.out.append(self.get_starttag_text())
        def handle_endtag(self, tag):
            if self.protected and self.protected[-1] == tag:
                self.protected.pop()
            self.out.append('</' + tag + '>')
        def handle_startendtag(self, tag, attrs):
            self.out.append(self.get_starttag_text())
        def handle_data(self, data):
            if not self.protected:
                data = messages.get(data, messages.get(data.strip(), display(data, lang=lang)))
            elif self.protected[-1] == 'script':
                # Explicitly allow only full visible phrases. Action identifiers
                # ('Start', 'Reboot', etc.) are translated by LABELS, not changed.
                for en, ko in catalog('javascript', lang).items():
                    data = data.replace(en, ko)
            self.out.append(data)
        def handle_entityref(self, name): self.out.append('&' + name + ';')
        def handle_charref(self, name): self.out.append('&#' + name + ';')
        def handle_decl(self, decl): self.out.append('<!' + decl + '>')
        def handle_comment(self, data): self.out.append('<!--' + data + '-->')
    parser = Translator(); parser.feed(text)
    return ''.join(parser.out).replace('<html>', '<html lang="ko">', 1)


def cell_width(char):
    if unicodedata.combining(char) or unicodedata.category(char) in ('Cf', 'Cc'):
        return 0
    return 2 if unicodedata.east_asian_width(char) in ('W', 'F') else 1


def clip(text, width):
    out = []
    used = 0
    for char in text:
        size = cell_width(char)
        if used + size > max(0, width):
            break
        out.append(char)
        used += size
    return ''.join(out)


def wrap(text, width):
    width = max(2, width)
    lines = []
    for paragraph in text.split('\n'):
        line = ''; used = 0
        for char in paragraph:
            size = cell_width(char)
            if used + size > width:
                lines.append(line); line = ''; used = 0
            line += char; used += size
        lines.append(line)
    return lines


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('action', choices=('language', 'set', 'title', 'task', 'filter', 'message'))
    ap.add_argument('args', nargs='*')
    a = ap.parse_args()
    state = os.environ.get('RHCSA_STATE', '/var/lib/rhcsa-sim')
    lang = language(state)
    if a.action == 'language':
        requested = os.environ.get('RHCSA_LANG')
        if requested and requested not in LANGUAGES:
            ap.error('지원 언어 / supported languages: ' + ', '.join(LANGUAGES))
        print(lang)
    elif a.action == 'set':
        if not a.args or a.args[0] not in LANGUAGES:
            ap.error('지원 언어 / supported languages: ' + ', '.join(LANGUAGES))
        save_language(state, a.args[0])
    elif a.action == 'title':
        print(title(a.args[0], a.args[1], lang))
    elif a.action == 'task':
        print(task_text(ROOT / 'tasks', a.args[0], a.args[1], state, lang), end='')
    elif a.action == 'message':
        print(display(a.args[0], state, lang), end='')
    elif a.action == 'filter':
        # A line-at-a-time filter keeps progress visible. ANSI and technical
        # identifiers are retained; this never feeds grading JSON or task data.
        for line in sys.stdin:
            print(display(line, state, lang), end='', flush=True)


if __name__ == '__main__':
    main()
