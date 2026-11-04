# bin

Own scripts called by Hyprland or systemd. They are versioned here and linked into
`~/.local/bin` (which is in `PATH`); `theme-setup` creates the links:

```sh
for f in ~/.config/bin/*; do [ "${f##*.}" = md ] || ln -sf "$f" ~/.local/bin/; done
```

| Script | Purpose |
| --- | --- |
| `theme-setup` | setup on a new machine (laptop): scripts, bash config, commit check, font, session services, theme; reports missing programs and sudo steps (`--check`: check only) |
| `theme` | switch the desktop theme (`theme`, `theme <name>`), see `themes/README.md` |
| `menu` | start menu (Super key, start button in the bar): the theme's own `startmenu.py` (winxp), hyprlauncher otherwise; stays in the background, every call shows or hides it |
| `idle-test` | test the idle chain (laptop: dimming, then screensaver, lock, DPMS) with short timeouts |
| `launcher-hide` | hide programs listed in `hypr/launcher-hidden.txt` from the launcher (they stay installed) |
| `theme-greeter` | adapt the login screen (sysc-greet) to the theme; once `sudo greeter-setup` |
| `greeter-setup` | one-time root setup for `theme-greeter` (with sudo) |
| `theme-browser` | build the browser theme (Helium) from `themes/<name>/browser.json` |
| `theme-fastfetch-logo` | build the fastfetch logo of the active theme: `private/logo.png` as pixel art, `fastfetch-logo.txt` otherwise (called by `theme`) |
| `video-tags` | mark windows with playing video so they are not dimmed (only for themes with dimming; runs on window and player events, `media-watch.service`) |
| `theme-wallpaper` | theme wallpaper by time of day (timer every 10 min) |
| `theme-sound` | play a theme sound (dunst, `theme-lock`) |
| `theme-lock` | lock with theme sounds (hypridle `lock_cmd`) |
| `screensaver` | start/stop the theme screensaver (hypridle); pauses once the monitors are off |
| `stream-deaths` | death counter for OBS (`Super+X`, `Super+Shift+X`, `Super+Ctrl+X`) |
| `stream-clip` | save the OBS replay buffer (`Super+C`) |
| `obs-ws` | minimal obs-websocket v5 client (Python stdlib) |
| `dotfiles-check` | check the repo: Lua, shell (with shellcheck if installed), Python, JSON, systemd units, the running Hyprland config; runs before every commit (`.githooks/pre-commit`) |
| `backup-check` | check backups and restart overdue ones (daily via `backup-check.timer`); `backup-check status` shows when each backup last succeeded |
| `stream-setup-backup` | copy the OBS/PipeWire setup to `~/Documents/Twitch/setup` (before `backup-storaged`) |
