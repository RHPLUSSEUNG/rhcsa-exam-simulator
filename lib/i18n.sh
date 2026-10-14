#!/usr/bin/env bash
# Presentation helpers are sourced only by the CLI, never by graders/setup.
i18n_init() {
  local arg; local rest=()
  while (( $# )); do
    case "$1" in
      --lang)
        (( $# >= 2 )) || { builtin echo '--lang requires ko or en' >&2; return 1; }
        RHCSA_LANG="$2"; shift 2 ;;
      --lang=*) RHCSA_LANG="${1#--lang=}"; shift ;;
      *) rest+=("$1"); shift ;;
    esac
  done
  RHCSA_LANG="$(RHCSA_LANG="${RHCSA_LANG:-}" python3 "$RHCSA_HOME/lib/i18n.py" language)" || return 1
  export RHCSA_LANG RHCSA_STATE PYTHONIOENCODING=utf-8
  I18N_ARGS=("${rest[@]}")
}
i18n_message() { python3 "$RHCSA_HOME/lib/i18n.py" message "$1"; }
i18n_text() { python3 "$RHCSA_HOME/lib/i18n.py" task "$1" "$2"; }
i18n_title() { python3 "$RHCSA_HOME/lib/i18n.py" title "$1" "$2"; }
info() { builtin printf '%s[*]%s %s\n' "$C_BLU" "$C_OFF" "$(i18n_message "$*")"; }
ok() { builtin printf '%s[+]%s %s\n' "$C_GRN" "$C_OFF" "$(i18n_message "$*")"; }
warn() { builtin printf '%s[!]%s %s\n' "$C_YEL" "$C_OFF" "$(i18n_message "$*")" >&2; }
err() { builtin printf '%s[x]%s %s\n' "$C_RED" "$C_OFF" "$(i18n_message "$*")" >&2; }
# Only known display phrases are mapped; task IDs, status markers and arbitrary
# shell output remain English. The shell's original builtins retain their flags.
i18n_echo() {
  if [[ "${RHCSA_LANG:-en}" == en ]]; then builtin echo "$@"
  else builtin echo "$@" | python3 "$RHCSA_HOME/lib/i18n.py" filter; fi
}
i18n_printf() {
  if [[ "${RHCSA_LANG:-en}" == en || "${1:-}" == -v ]]; then builtin printf "$@"
  else local fmt; fmt="$(i18n_message "$1")"; shift; builtin printf "$fmt" "$@"; fi
}
i18n_read() {
  local args=() arg
  while (( $# )); do
    if [[ "$1" == -p && $# -ge 2 ]]; then
      args+=(-p "$(i18n_message "$2")"); shift 2
    else args+=("$1"); shift; fi
  done
  builtin read "${args[@]}"
}
