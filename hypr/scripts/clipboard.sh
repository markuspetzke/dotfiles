#!/usr/bin/env bash
set -euo pipefail
umask 077

selection=$(cliphist list | hyprlauncher -m) || exit 0
[[ -n "$selection" ]] || exit 0

# A file instead of a shell variable: keeps images and trailing newlines intact.
tmp=$(mktemp "${XDG_RUNTIME_DIR:-${TMPDIR:-/tmp}}/hypr-clipboard.XXXXXX")
trap 'rm -f -- "$tmp"' EXIT
printf '%s\n' "$selection" | cliphist decode >"$tmp"
wl-copy <"$tmp"
