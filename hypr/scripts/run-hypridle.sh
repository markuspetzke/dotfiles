#!/usr/bin/env bash
set -euo pipefail

profile=$("$HOME/.config/hypr/scripts/hypr-profile.sh")
if [[ "$profile" == laptop ]]; then
  exec /usr/bin/hypridle -c "$HOME/.config/hypr/hypridle-laptop.conf"
fi
exec /usr/bin/hypridle -c "$HOME/.config/hypr/hypridle.conf"
