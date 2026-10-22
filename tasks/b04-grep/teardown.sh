#!/usr/bin/env bash
rm -f /root/lines
if [[ -f "$RHCSA_STATE/b04-words.saved" ]]; then
  if [[ -f "$RHCSA_STATE/b04-words.bak" ]]; then mv "$RHCSA_STATE/b04-words.bak" /usr/share/dict/words; else rm -f /usr/share/dict/words; fi
  rm -f "$RHCSA_STATE/b04-words.saved"
fi
exit 0
