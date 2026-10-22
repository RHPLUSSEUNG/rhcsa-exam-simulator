#!/usr/bin/env bash
# Read-only exam 04 smoke checks. No lab setup, solver or grader is executed.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

while IFS= read -r file; do
  bash -n "$file"
done < <(find "$ROOT/tasks" "$ROOT/tests/solvers" -type f \
  \( -path '*/b04-*/*.sh' -o -name 'b04-*.sh' \) -print)

RHCSA_HOME="$ROOT" RHCSA_STATE="$(mktemp -d)" RHCSA_RHEL=10 bash -c '
  trap '\''rm -rf "$RHCSA_STATE"'\'' EXIT
  . "$RHCSA_HOME/lib/common.sh"
  test "$(exam_rhel exam-r10-2node-04)" = 10
  exam_rhel_ok exam-r10-2node-04
  ! RHCSA_RHEL=9 exam_rhel_ok exam-r10-2node-04
  test "$(grep -Ev "^[[:space:]]*(#|$)" "$RHCSA_HOME/exams/exam-r10-2node-04.2node.list" | wc -l)" -eq 24
  while read -r node task; do
    task_exists "$task"
    grep -qx "TASK_RHEL=\"10\"" "$RHCSA_HOME/tasks/$task/meta.sh" || [[ "$task" =~ ^(e2-network|e2-repo|e2-repo2|root-password|tuning-profile)$ ]]
  done < <(grep -Ev "^[[:space:]]*(#|$)" "$RHCSA_HOME/exams/exam-r10-2node-04.2node.list")
'

echo 'exam-r10-2node-04 static smoke checks: PASS'
