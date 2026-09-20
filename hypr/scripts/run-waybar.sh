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

exec /usr/bin/waybar -c "$HOME/.config/waybar/config-${profile}.jsonc"
