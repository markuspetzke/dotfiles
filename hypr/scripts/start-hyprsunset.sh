#!/usr/bin/env bash
set -euo pipefail

pgrep -u "$(id -u)" -x hyprsunset >/dev/null && exit 0
if [[ -x /usr/bin/hyprsunset ]]; then
  exec /usr/bin/hyprsunset
elif command -v hyprsunset >/dev/null; then
  exec hyprsunset
elif [[ -x "$HOME/.local/bin/hyprsunset" ]]; then
  exec "$HOME/.local/bin/hyprsunset"
else
  notify-send 'Abendprofil' 'hyprsunset fehlt: sudo pacman -S hyprsunset'
  exit 1
fi
