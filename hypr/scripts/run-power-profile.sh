#!/usr/bin/env bash
set -euo pipefail

if ! command -v powerprofilesctl >/dev/null; then
  echo 'powerprofilesctl missing; install power-profiles-daemon' >&2
  exit 0
fi

# AC/battery (including USB-C charging) comes from power-source.sh; without a system battery it is always "ac".
power_source="$HOME/.config/hypr/scripts/power-source.sh"

# Set the profile only at startup and when switching between AC and battery. In between
# a manual choice (Waybar click) is kept instead of being overwritten every 30 s.
last=""
while :; do
  desired=balanced
  if [[ "$("$power_source")" == battery ]]; then
    desired=power-saver
  fi
  if [[ "$desired" != "$last" ]]; then
    powerprofilesctl set "$desired" || true
    last=$desired
  fi
  sleep 30
done
