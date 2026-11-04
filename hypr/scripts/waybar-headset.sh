#!/usr/bin/env bash
# Waybar: battery level of the Arctis 7 through headsetcontrol (JSON output).
set -u

if ! command -v headsetcontrol >/dev/null 2>&1; then
    printf '%s\n' '{"text":"","class":"unavailable","tooltip":"headsetcontrol is not installed"}'
    exit 0
fi

# "STATUS LEVEL MINUTES" from the first headset found, empty otherwise.
# When the headset is off, the dongle still reports BATTERY_AVAILABLE with level 0.
read -r status level minutes < <(headsetcontrol -b -o json 2>/dev/null | python3 -c '
import json, sys
b = json.load(sys.stdin)["devices"][0]["battery"]
print(b["status"], b["level"], b.get("time_to_empty_min", -1))' 2>/dev/null) || true

case "${status:-}" in
    BATTERY_CHARGING)
        printf '{"text":"󰂄 %s%%","class":"charging","tooltip":"Arctis 7: charging (%s%%)"}\n' "$level" "$level"
        ;;
    BATTERY_AVAILABLE)
        if ((level <= 0)); then
            printf '%s\n' '{"text":"","class":"off","tooltip":"Arctis 7: off"}'
            exit 0
        fi
        remaining=""
        ((${minutes:--1} > 0)) && remaining=$(printf '\\nabout %dh %02dmin left' $((minutes / 60)) $((minutes % 60)))
        # Battery icon by level (10 % steps), so it is clearly different from the
        # headphone icon of the volume module.
        icons=(󰂎 󰁺 󰁻 󰁼 󰁽 󰁾 󰁿 󰂀 󰂁 󰂂 󰁹)
        icon=${icons[$(((level + 5) / 10))]}
        class=normal
        ((level <= 30)) && class=warning
        ((level <= 15)) && class=critical
        printf '{"text":"%s %s%%","class":"%s","tooltip":"Arctis 7: %s%%%s"}\n' "$icon" "$level" "$class" "$level" "$remaining"
        ;;
    *)
        printf '%s\n' '{"text":"","class":"off","tooltip":"Arctis 7: off / not connected"}'
        ;;
esac
