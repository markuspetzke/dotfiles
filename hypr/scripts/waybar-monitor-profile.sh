#!/usr/bin/env bash
set -u

state="$HOME/.config/hypr/.monitor-profile"
profile=$(cat "$state" 2>/dev/null || printf 'auto')
external=0
if command -v hyprctl >/dev/null 2>&1; then
    if command -v jq >/dev/null 2>&1; then
        external=$(hyprctl monitors -j 2>/dev/null | jq '[.[] | select(.name != "eDP-1" and (.disabled // false) == false)] | length' 2>/dev/null || printf '0')
    else
        external=$(hyprctl monitors 2>/dev/null | awk '$1 == "Monitor" && $2 != "eDP-1" { count++ } END { print count + 0 }')
    fi
fi

case "$profile" in
    mobile) icon='󰍹'; label='Mobile' ;;
    extended) icon='󰍺'; label='Extended' ;;
    presentation) icon='󰍹'; label='Presentation' ;;
    *) icon='󰍹'; label='Auto' ; profile='auto' ;;
esac

printf '{"text":"%s %s","class":"%s","tooltip":"Monitorprofil: %s\\nExterne Displays: %s\\nSuper+Ctrl+F1/F2/F3 zum Umschalten"}\n' \
    "$icon" "$label" "$profile" "$label" "$external"
