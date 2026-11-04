#!/bin/sh
# Waybar (Office-Theme): Zeit bis Feierabend (17:00), danach Ueberstunden; am Wochenende frei.
# Ausgabe als JSON, im Tooltip ein zufaelliges Zitat aus quotes.txt.
dir=$(dirname "$0")
dow=$(date +%u); now=$(date +%H%M); h=$(date +%-H); m=$(date +%-M)
if [ "$dow" -ge 6 ]; then text="Wochenende"
elif [ "$now" -lt 0800 ]; then text="Noch nicht im Büro"
else
	left=$(( 17 * 60 - (h * 60 + m) ))
	if [ "$left" -gt 0 ]; then
		text=$(printf 'Feierabend in %d:%02d' $((left / 60)) $((left % 60)))
	else
		over=$(( -left ))
		text=$(printf 'Überstunden: %d:%02d' $((over / 60)) $((over % 60)))
	fi
fi
quote=$(shuf -n1 "$dir/quotes.txt" 2>/dev/null | sed 's/"/\\"/g')
printf '{"text": "%s", "tooltip": "%s"}\n' "$text" "$quote"
