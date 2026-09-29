#!/usr/bin/env bash
set -euo pipefail

profile=$("$HOME/.config/hypr/scripts/hypr-profile.sh")
exec /usr/bin/waybar -c "$HOME/.config/waybar/config-${profile}.jsonc"
