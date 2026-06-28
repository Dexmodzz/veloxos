#!/usr/bin/env bash
niri msg action switch-layout next
name=$(niri msg --json keyboard-layouts \
  | python3 -c 'import sys,json; d=json.load(sys.stdin); print(d["names"][d["current_idx"]])')

notify-send \
  -a "Keyboard-Layout" \
  -t 1000 \
  -i input-keyboard \
  -h string:x-canonical-private-synchronous:kblayout \
  -h int:transient:1 \
  "$name"