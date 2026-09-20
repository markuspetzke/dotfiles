#!/usr/bin/env bash
set -euo pipefail

if [[ -x /usr/bin/hyprsunset ]]; then
  exec /usr/bin/hyprsunset
elif [[ -x "$HOME/.local/bin/hyprsunset" ]]; then
  exec "$HOME/.local/bin/hyprsunset"
fi
echo 'hyprsunset is not installed' >&2
exit 127
