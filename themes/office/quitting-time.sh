#!/bin/sh
# Waybar (office theme): time until quitting time (17:00), overtime after that; weekends off.
# Output as JSON, with a random quote from quotes.txt in the tooltip.
dir=$(dirname "$0")
dow=$(date +%u); now=$(date +%H%M); h=$(date +%-H); m=$(date +%-M)
if [ "$dow" -ge 6 ]; then text="Weekend"
elif [ "$now" -lt 0800 ]; then text="Not in the office yet"
else
	left=$(( 17 * 60 - (h * 60 + m) ))
	if [ "$left" -gt 0 ]; then
		text=$(printf 'Quitting time in %d:%02d' $((left / 60)) $((left % 60)))
	else
		over=$(( -left ))
		text=$(printf 'Overtime: %d:%02d' $((over / 60)) $((over % 60)))
	fi
fi
quote=$(shuf -n1 "$dir/quotes.txt" 2>/dev/null | sed 's/"/\\"/g')
printf '{"text": "%s", "tooltip": "%s"}\n' "$text" "$quote"
