#!/usr/bin/env bash
# Waybar: aktuelles Power-Profil als Symbol (Name im Tooltip). "toggle" wechselt reihum.
set -u

if ! command -v powerprofilesctl >/dev/null 2>&1; then
    printf '%s\n' '{"text":"󰾆","class":"unavailable","tooltip":"power-profiles-daemon ist nicht installiert"}'
    exit 0
fi

profile=$(powerprofilesctl get 2>/dev/null || printf 'unknown')

if [[ "${1:-}" == toggle ]]; then
    case "$profile" in
        power-saver) next=balanced ;;
        balanced) next=performance ;;
        *) next=power-saver ;;
    esac
    powerprofilesctl set "$next" >/dev/null 2>&1 && profile="$next"
fi

case "$profile" in
    performance) icon='󰓅'; label='Performance' ;;
    balanced) icon='󰾅'; label='Balanced' ;;
    power-saver) icon='󰾆'; label='Energiesparen' ;;
    *) icon='󰾆'; label="$profile" ;;
esac

printf '{"text":"%s","class":"%s","tooltip":"Power-Profil: %s\\nKlick: wechseln · Rechtsklick: Details"}\n' \
    "$icon" "$profile" "$label"
