#!/usr/bin/env bash
# Gibt das Hardwareprofil aus: desktop oder laptop.
# HYPR_PROFILE gewinnt, sonst entscheidet ein Systemakku. Ohne Akku immer desktop --
# ein unbekannter Rechner bekommt so nie die Laptop-Logik (Hibernate nach 15 min).
# Einzige Quelle fuer host.lua, run-hypridle.sh, run-waybar.sh und die User-Units.
set -euo pipefail

profile=${HYPR_PROFILE:-}
if [[ "$profile" != desktop && "$profile" != laptop ]]; then
  profile=desktop
  for supply in /sys/class/power_supply/*; do
    [[ -r "$supply/type" && "$(<"$supply/type")" == Battery ]] || continue
    # Maus-/Headset-Akkus melden scope=Device; Systemakkus haben kein scope oder System.
    [[ -r "$supply/scope" && "$(<"$supply/scope")" == Device ]] && continue
    profile=laptop
    break
  done
fi
printf '%s\n' "$profile"
