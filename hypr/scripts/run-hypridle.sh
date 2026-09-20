#!/usr/bin/env bash
set -euo pipefail

profile=${HYPR_PROFILE:-}
if [[ "$profile" != desktop && "$profile" != laptop ]]; then
  profile=desktop
  for battery in /sys/class/power_supply/BAT*/type; do
    [[ -r "$battery" ]] && profile=laptop && break
  done
  [[ "$profile" == desktop && "$(hostname)" != GLaDOS ]] && profile=laptop
fi

if [[ "$profile" == laptop ]]; then
  exec /usr/bin/hypridle -c "$HOME/.config/hypr/hypridle-laptop.conf"
fi
exec /usr/bin/hypridle -c "$HOME/.config/hypr/hypridle.conf"
