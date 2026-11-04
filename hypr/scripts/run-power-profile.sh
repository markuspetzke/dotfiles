#!/usr/bin/env bash
set -euo pipefail

if ! command -v powerprofilesctl >/dev/null; then
  echo 'powerprofilesctl fehlt; installiere power-profiles-daemon' >&2
  exit 0
fi

# Netzteil/Akku (auch USB-C-Laden) erkennt power-source.sh; ohne Systemakku gilt immer "ac".
power_source="$HOME/.config/hypr/scripts/power-source.sh"

# Profil nur beim Start und beim Wechsel Netzteil <-> Akku setzen. Dazwischen
# bleibt eine manuelle Wahl (Waybar-Klick) erhalten, statt alle 30 s ueberschrieben
# zu werden.
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
