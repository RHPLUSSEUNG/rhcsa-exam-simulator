#!/usr/bin/env bash
# Read-only CLI smoke test. Only the temporary state directory is written.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMP="$(mktemp -d)"
trap 'rm -rf "$TEMP"' EXIT
export RHCSA_HOME="$ROOT" RHCSA_STATE="$TEMP/state" RHCSA_RHEL=9
unset RHCSA_LANG || true
if [[ -n "${RHCSA_TEST_PYTHON:-}" ]]; then
  mkdir -p "$TEMP/bin"
  cat > "$TEMP/bin/python3" <<'SH'
#!/usr/bin/env bash
if command -v cygpath >/dev/null 2>&1; then
  export RHCSA_STATE="$(cygpath -w "$RHCSA_STATE")" RHCSA_HOME="$(cygpath -w "$RHCSA_HOME")"
fi
exec "$RHCSA_TEST_PYTHON" "$@"
SH
  chmod +x "$TEMP/bin/python3"
  export PATH="$TEMP/bin:$PATH"
fi
run(){ bash "$ROOT/bin/rhcsa-sim" "$@"; }
run help > "$TEMP/ko-help"
grep -q '빠른 시작' "$TEMP/ko-help"
run --lang en help > "$TEMP/en-help"
grep -q 'QUICK START' "$TEMP/en-help"
run help --lang en > "$TEMP/en-after"
cmp "$TEMP/en-help" "$TEMP/en-after"
run lang en > /dev/null
[[ "$(run lang)" == en ]]
run --lang ko status > "$TEMP/status"
grep -q '진행 중인 시험이 없습니다' "$TEMP/status"
[[ "$(run lang)" == en ]]  # One invocation does not overwrite saved preference.
run lang ko > /dev/null
mkdir -p "$RHCSA_STATE/params"
printf 'DIR=testdir\nG=testgroup\n' > "$RHCSA_STATE/params/acl-default.env"
cp "$RHCSA_STATE/params/acl-default.env" "$TEMP/before"
run --lang ko hint acl-default > "$TEMP/ko-hint"
grep -q '접근 방법' "$TEMP/ko-hint"
run --lang en hint acl-default > "$TEMP/en-hint"
grep -q 'Approach:' "$TEMP/en-hint"
run --lang ko solution acl-default > "$TEMP/ko-solution"
grep -q '참고 풀이' "$TEMP/ko-solution"
grep -q '/testdir' "$TEMP/ko-solution"
run --lang en solution acl-default > "$TEMP/en-solution"
grep -q 'Reference solution' "$TEMP/en-solution"
grep -q '/testdir' "$TEMP/en-solution"
cmp "$TEMP/before" "$RHCSA_STATE/params/acl-default.env"
if run --lang invalid help > /dev/null 2>&1; then exit 1; fi
echo 'CLI localization smoke tests passed'
