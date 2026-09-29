#!/usr/bin/env bash
# Waybar: Akkustand des Arctis 7 ueber headsetcontrol (JSON-Ausgabe).
set -u

if ! command -v headsetcontrol >/dev/null 2>&1; then
    printf '%s\n' '{"text":"","class":"unavailable","tooltip":"headsetcontrol ist nicht installiert"}'
    exit 0
fi

# "STATUS LEVEL MINUTEN" aus dem ersten gefundenen Headset, sonst leer.
# Ist das Headset aus, meldet der Dongle trotzdem BATTERY_AVAILABLE mit Level 0.
read -r status level minutes < <(headsetcontrol -b -o json 2>/dev/null | python3 -c '
import json, sys
b = json.load(sys.stdin)["devices"][0]["battery"]
print(b["status"], b["level"], b.get("time_to_empty_min", -1))' 2>/dev/null) || true

case "${status:-}" in
    BATTERY_CHARGING)
        printf '{"text":"󰂄 %s%%","class":"charging","tooltip":"Arctis 7: laedt (%s%%)"}\n' "$level" "$level"
        ;;
    BATTERY_AVAILABLE)
        if ((level <= 0)); then
            printf '%s\n' '{"text":"","class":"off","tooltip":"Arctis 7: aus"}'
            exit 0
        fi
        remaining=""
        ((${minutes:--1} > 0)) && remaining=$(printf '\\nnoch ca. %dh %02dmin' $((minutes / 60)) $((minutes % 60)))
        # Akku-Symbol nach Fuellstand (10%-Stufen), damit es sich klar vom
        # Kopfhoerer-Symbol der Lautstaerke unterscheidet.
        icons=(󰂎 󰁺 󰁻 󰁼 󰁽 󰁾 󰁿 󰂀 󰂁 󰂂 󰁹)
        icon=${icons[$(((level + 5) / 10))]}
        class=normal
        ((level <= 30)) && class=warning
        ((level <= 15)) && class=critical
        printf '{"text":"%s %s%%","class":"%s","tooltip":"Arctis 7: %s%%%s"}\n' "$icon" "$level" "$class" "$level" "$remaining"
        ;;
    *)
        printf '%s\n' '{"text":"","class":"off","tooltip":"Arctis 7: aus / nicht verbunden"}'
        ;;
esac
