#!/usr/bin/env bash
set -u

if ! command -v powerprofilesctl >/dev/null 2>&1; then
    printf '%s\n' '{"text":"󰾆 N/A","class":"unavailable","tooltip":"power-profiles-daemon ist nicht installiert"}'
    exit 0
fi

profile=$(powerprofilesctl get 2>/dev/null || printf 'unknown')
case "$profile" in
    performance) icon='󰓅'; label='Performance' ; class='performance' ;;
    balanced) icon='󰾅'; label='Balanced' ; class='balanced' ;;
    power-saver) icon='󰾆'; label='Power saver' ; class='power-saver' ;;
    *) icon='󰾆'; label="$profile" ; class='unknown' ;;
esac

if [[ "${1:-}" == toggle ]]; then
    case "$profile" in
        power-saver) next=balanced ;;
        balanced) next=performance ;;
        *) next=power-saver ;;
    esac
    powerprofilesctl set "$next" >/dev/null 2>&1 || true
    profile="$next"
fi

printf '{"text":"%s %s","class":"%s","tooltip":"Power-Profil: %s\\nKlick: Profil wechseln"}\n' \
    "$icon" "$label" "$class" "$label"
