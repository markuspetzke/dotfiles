# Themes

Each theme is a folder with the same set of files. The actual configs only include the
active theme: `~/.config/theme-current` -> `themes/<name>`.
The symlink is not in git, so every machine has its own theme.

```sh
theme            # list, active one marked with *
theme wired      # switch and reload everything
```

After a fresh clone (e.g. on the laptop) run `~/.config/bin/theme-setup` once:
font, scripts, timers, launcher and theme in one step.

On the laptop (profile `laptop`) the shader and the animated border are off by default
(battery); `Super+Shift+G` turns the shader on when needed.

| Theme | Style |
| --- | --- |
| `tokyonight` | The setup from before the retro themes: rounded corners, blur, shadows, pill bar, FiraCode |
| `winxp` | Windows XP (Luna): blue taskbar with green start button, hills wallpaper, yellow balloons, dark console |
| `office` | The Office (Dunder Mifflin Scranton), dark: rooms as workspaces, quitting-time counter, quotes, memo, time clock, World's Best Boss mug |
| `retro` | Amber CRT: warm black, cream, amber |
| `wired` | Lain: phosphor green and violet, terminal bar, power pole |
| `win31` | Windows 3.1: teal desktop, system gray, bevel buttons, DOS terminal |

## Files of a theme

| File | Included by |
| --- | --- |
| `palette.lua` | `hypr/theme.lua` (border colors, border width, dimming) |
| `waybar-colors.css`, `waybar.css` | `waybar/style.css` (colors, then `base.css`, then overrides) |
| `waybar-modules.jsonc` | `waybar/config*.jsonc` (overrides only; included before `modules.jsonc`) |
| `kitty.conf` | `include` at the end of `kitty/kitty.conf` |
| `hyprlock.conf` | `source` in `hypr/hyprlock.conf` |
| `greeter.toml` | login screen colors (sysc-greet); once `sudo ~/.config/bin/greeter-setup` |
| `thunar.css` | Thunar windows (included through `gtk-3.0/gtk.css`); Thunar reads it only at startup, `theme` quits a Thunar without open windows |
| `(private/)icon-theme/<Name>/` | icon theme (gsettings), e.g. XP folders in Thunar; Adwaita otherwise |
| `themes/spicetify/color.ini` (section `[<name>]`), `user.css` | Spotify colors through Spicetify (theme `DesktopTheme`); applies after restarting Spotify |
| `hyprtoolkit.conf` | symlink `hypr/hyprtoolkit.conf` (launcher) |
| `dunst.conf` | symlink `dunst/dunstrc.d/50-theme.conf` |
| `fastfetch.jsonc`, `fastfetch-logo.txt` | symlink `fastfetch/config.jsonc` |
| `nvim.lua` | `nvim/lua/config/theme.lua` (colorscheme, gruvbox overrides, highlights) |
| `wallpaper.png`, `wallpaper.py` | `bin/theme-wallpaper` -> `~/.local/state/theme/wallpaper.png` (hyprpaper, hyprlock); `wallpaper.py` generates the images |

## Optional extras

| File | Effect | Themes |
| --- | --- | --- |
| `shader.frag` | screen shader; `Super+Shift+G` toggles it, off automatically in fullscreen games | retro (scanlines, slight amber tint), wired (tube) |
| `palette.lua`: `border_gradient`, `border_loop` | gradient border (optionally rotating) | tokyonight, winxp, wired (rotating) |
| `palette.lua`: `config`, `animations`, `window_rules` | overrides Hyprland settings from `hypr/hyprland.lua` (the theme is loaded last) | tokyonight (rounding, blur, shadows, transparent kitty), office (rounding, shadows) |
| `nvim.lua`: `background` | light or dark Neovim (default: dark) | (none light at the moment) |
| `wallpaper-rotate` + `wallpapers/*.png` | cycle through wallpapers (interval in seconds) | tokyonight (hourly) |
| `wallpaper-phases` + `wallpapers/<phase>.png` | wallpaper by time of day (`theme-wallpaper.timer`, every 10 min) | winxp (day/evening/night), office (day/evening/night), retro (moving sun), wired (day/dusk/night) |
| `sounds/{notify,lock,unlock}.wav` (+ `sounds.py`), optionally `critical`, `startup`, `shutdown` | sounds for notifications (dunst; `critical` for high urgency), lock/unlock (`bin/theme-lock`), session start (`theme --session`) and shutdown in the start menu; your own files in `private/sounds/` take precedence | winxp (ding, chord), office (phone, stamp, typing + ding), retro (relay, tube on/off), wired (modem), win31 (bell, chord) |
| `cursor/<Name>/` (+ `cursor.py`, writer: `themes/xcursor.py`) | own pointer arrow, everything else inherited from the Wii pointer | winxp (arrow with shadow), office (white arrow), retro (amber arrow), wired (crosshair), win31 (arrow) |
| `screensaver.py` | screensaver after 9 min (`bin/screensaver`, hypridle) | winxp (pipes), office (conference room note), retro (wandering clock), wired (hex rain), win31 (starfield) |
| `nvim.lua`: `dashboard_header` | header of the Neovim start screen | winxp ("Welcome" window), office (memo), retro (sun + READY.), wired, win31 |
| `browser.json` | colors for Helium; `bin/theme-browser` builds `~/.local/share/theme-browser` from it (load once as an unpacked extension, see `bin/theme-browser`; applies after restarting Helium) | all |
| `hyprtoolkit.conf` | launcher (hyprlauncher); `theme` restarts the daemon | all |
| `startmenu.py` | own start menu instead of hyprlauncher (Super key, start button; `bin/menu`) | winxp (XP start menu) |
| `icons.py` + `icons/*.png` | start menu icons (own drawings); originals in `private/icons/` take precedence | winxp |
| `private/logo.png` (+ `logo.conf`) | own logo on the lock screen and as the fastfetch logo; `logo.conf` sets position and size | winxp, office |
| `quotes.txt` | random quote in fastfetch, on the lock screen and in the tooltip of the quitting-time counter | office |
| `kitty-scanlines.png` | scanline texture in the terminal | wired |
| `kitty.conf`: `cursor_trail` | phosphor afterglow behind the cursor | retro |
| `waybar-modules.jsonc` | own module formats, e.g. segment bars `CPU ▮▮▯▯▯` (retro), text labels (wired) | retro, wired, office (rooms as workspaces, quitting-time counter `quitting-time.sh`) |

The generators (`wallpaper.py`, `sounds.py`, `cursor.py`) recreate the files, e.g. after
changing colors: `python3 themes/wired/wallpaper.py`.

New theme: copy a folder, adjust the colors, `theme <name>`.

Your own images, logos and sounds that must not be public go into `themes/<name>/private/`
(ignored by git). What goes where: `themes/winxp/PRIVATE.md`, `themes/office/PRIVATE.md`.
