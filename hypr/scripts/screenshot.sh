#!/usr/bin/env bash
set -euo pipefail
umask 077

mode=${1:-clipboard}
case "$mode" in
clipboard | file) ;;
*)
  printf 'Usage: %s [clipboard|file]\n' "$0" >&2
  exit 2
  ;;
esac

# Esc must neither take a screenshot nor clear the clipboard.
geometry=$(slurp -d) || exit 0
[[ -n "$geometry" ]] || exit 0

tmp=$(mktemp "${XDG_RUNTIME_DIR:-${TMPDIR:-/tmp}}/hypr-shot.XXXXXX.png")
trap 'rm -f -- "$tmp"' EXIT
grim -g "$geometry" "$tmp"

image=$tmp
if [[ "$mode" == file ]]; then
  pictures=$(xdg-user-dir PICTURES 2>/dev/null) || pictures="$HOME/Pictures"
  directory="${pictures:-$HOME/Pictures}/Screenshots"
  mkdir -p -- "$directory"
  image="$directory/$(date +%Y-%m-%d_%H-%M-%S_%N).png"
  cp -- "$tmp" "$image"
fi

# Copy only after a successful capture, with an explicit MIME type.
wl-copy --type image/png <"$image"
