#!/usr/bin/env bash
# Prints the hardware profile: desktop or laptop.
# HYPR_PROFILE wins, otherwise a system battery decides. Without a battery always desktop --
# so an unknown machine never gets the laptop logic (hibernate after 15 min).
# Single source for host.lua, run-hypridle.sh, run-waybar.sh and the user units.
set -euo pipefail

profile=${HYPR_PROFILE:-}
if [[ "$profile" != desktop && "$profile" != laptop ]]; then
  profile=desktop
  for supply in /sys/class/power_supply/*; do
    [[ -r "$supply/type" && "$(<"$supply/type")" == Battery ]] || continue
    # Mouse/headset batteries report scope=Device; system batteries have no scope or System.
    [[ -r "$supply/scope" && "$(<"$supply/scope")" == Device ]] && continue
    profile=laptop
    break
  done
fi
printf '%s\n' "$profile"
