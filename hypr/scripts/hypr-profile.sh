#!/usr/bin/env bash
# Gibt das Hardwareprofil aus: desktop oder laptop.
# HYPR_PROFILE gewinnt, danach Akku-Erkennung, zuletzt der Hostname.
# Einzige Quelle fuer host.lua, run-hypridle.sh und run-waybar.sh.
set -euo pipefail

profile=${HYPR_PROFILE:-}
if [[ "$profile" != desktop && "$profile" != laptop ]]; then
  profile=desktop
  for battery in /sys/class/power_supply/BAT*/type; do
    [[ -r "$battery" ]] && profile=laptop && break
  done
  [[ "$profile" == desktop && "$(</etc/hostname)" != GLaDOS ]] && profile=laptop
fi
printf '%s\n' "$profile"
