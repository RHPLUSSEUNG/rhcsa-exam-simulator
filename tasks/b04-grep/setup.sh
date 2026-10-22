#!/usr/bin/env bash
mkdir -p /usr/share/dict
if [[ ! -e "$RHCSA_STATE/b04-words.saved" ]]; then
  [[ ! -e /usr/share/dict/words ]] || cp -a /usr/share/dict/words "$RHCSA_STATE/b04-words.bak"
  touch "$RHCSA_STATE/b04-words.saved"
fi
printf 'rich\nplain\nwhich\nICH\nlichen\n' >/usr/share/dict/words
echo 'b04-grep: dictionary fixture ready'
exit 0
