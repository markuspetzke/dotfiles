#!/usr/bin/env bash
set -euo pipefail

if ! command -v powerprofilesctl >/dev/null; then
  echo 'powerprofilesctl fehlt; installiere power-profiles-daemon' >&2
  exit 0
fi

on_ac_power() {
  for charger in /sys/class/power_supply/AC*/online /sys/class/power_supply/ADP*/online; do
    [[ -r "$charger" ]] && [[ "$(<"$charger")" == 1 ]] && return 0
  done
  return 1
}

has_battery() {
  for battery in /sys/class/power_supply/BAT*/type; do
    [[ -r "$battery" ]] && [[ "$(<"$battery")" == Battery ]] && return 0
  done
  return 1
}

while :; do
  desired=balanced
  # Desktops have no battery and should stay balanced even when no AC
  # power_supply entry exists.
  if has_battery && ! on_ac_power; then
    desired=power-saver
  fi
  current=$(powerprofilesctl get 2>/dev/null || true)
  if [[ "$current" != "$desired" ]]; then
    powerprofilesctl set "$desired" || true
  fi
  sleep 30
done
