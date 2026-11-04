#!/usr/bin/env bash
# waybar.service: Waybar with the config of the hardware profile (waybar/config-<profile>.jsonc).
set -euo pipefail

profile=$("$HOME/.config/hypr/scripts/hypr-profile.sh")
exec /usr/bin/waybar -c "$HOME/.config/waybar/config-${profile}.jsonc"
