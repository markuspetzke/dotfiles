#!/usr/bin/env bash
# The playerctl template lives here: Hyprlang treats {{...}} as an expression.
playerctl -a metadata --format '{{markup_escape(artist)}} — {{markup_escape(title)}}' 2>/dev/null | head -n 1
