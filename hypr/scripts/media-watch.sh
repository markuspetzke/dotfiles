#!/usr/bin/env bash
# Watches media playback through playerctl (event based, no polling):
#  1. While a player reports "Playing", it holds an idle inhibitor (systemd-inhibit --what=idle).
#     hypridle then fires no stage (screensaver, lock, monitors off, suspend), and once
#     playback ends the chain starts over. A condition in on-timeout ("only if nothing
#     plays") is not enough: hypridle runs each stage only once per idle period, so a stage
#     that came due during playback would be skipped until the next input.
#  2. On every change (play/pause/title) it runs bin/video-tags if the theme dims inactive
#     windows: windows with playing video stay bright.
# Runs as media-watch.service (hypr-session.target).
set -u

inhibit_pid=""

release() {
	if [[ -n $inhibit_pid ]]; then
		kill "$inhibit_pid" 2>/dev/null
		inhibit_pid=""
	fi
}
trap release EXIT
trap 'exit 0' TERM INT

update() {
	if playerctl -a status 2>/dev/null | grep -qx Playing; then
		if [[ -z $inhibit_pid ]] || ! kill -0 "$inhibit_pid" 2>/dev/null; then
			systemd-inhibit --what=idle --who=media-watch --why="Audio/video is playing" sleep infinity &
			inhibit_pid=$!
		fi
	else
		release
	fi
	if hyprctl -j getoption decoration:dim_inactive 2>/dev/null | grep -q '"bool": true'; then
		"$HOME/.config/bin/video-tags"
	fi
}

update
# One line per change of status or title of any player
while read -r _; do
	update
done < <(playerctl -a -F metadata --format '{{playerName}} {{status}} {{title}}' 2>/dev/null)
# playerctl exited: systemd restarts the service
exit 1
