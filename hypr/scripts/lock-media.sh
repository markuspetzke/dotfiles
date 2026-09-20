#!/usr/bin/env bash
# Playerctl-Vorlage auslagern: Hyprlang interpretiert {{...}} als Ausdruck.
playerctl -a metadata --format '{{markup_escape(artist)}} — {{markup_escape(title)}}' 2>/dev/null | head -n 1
