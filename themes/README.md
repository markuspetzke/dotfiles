# Themes

Jedes Theme ist ein Ordner mit denselben Dateien. Die eigentlichen Configs binden
nur das aktive Theme ein: `~/.config/theme-current` -> `themes/<name>`.
Der Symlink ist nicht im Git, jeder Rechner hat sein eigenes Theme.

```sh
theme            # Liste, aktives mit *
theme wired      # umschalten und alles neu laden
```

Nach einem frischen Clone einmal `theme retro` (oder ein anderes) ausfuehren.

| Theme | Stil |
| --- | --- |
| `retro` | Bernstein-CRT: warmes Schwarz, Creme, Bernstein |
| `wired` | Lain: Phosphorgruen und Violett, Terminal-Leiste, Strommast |
| `win31` | Windows 3.1: Teal-Desktop, Systemgrau, Bevel-Knoepfe, DOS-Terminal |

## Dateien eines Themes

| Datei | Eingebunden von |
| --- | --- |
| `palette.lua` | `hypr/theme.lua` (Rahmenfarben, Rahmenbreite, Abdunkeln) |
| `waybar-colors.css`, `waybar.css` | `waybar/style.css` (Farben, dann `base.css`, dann Abweichungen) |
| `waybar-modules.jsonc` | `waybar/config*.jsonc` (nur Abweichungen; wird vor `modules.jsonc` eingebunden) |
| `kitty.conf` | `include` am Ende von `kitty/kitty.conf` |
| `hyprlock.conf` | `source` in `hypr/hyprlock.conf` |
| `hyprtoolkit.conf` | Symlink `hypr/hyprtoolkit.conf` (Launcher) |
| `dunst.conf` | Symlink `dunst/dunstrc.d/50-theme.conf` |
| `fastfetch.jsonc`, `fastfetch-logo.txt` | Symlink `fastfetch/config.jsonc` |
| `nvim.lua` | `nvim/lua/config/theme.lua` (Colorscheme, gruvbox-Overrides, Highlights) |
| `wallpaper.png`, `wallpaper.py` | `hypr/hyprpaper.conf`, Hyprlock; `wallpaper.py` erzeugt das Bild |

Neues Theme: Ordner kopieren, Farben anpassen, `theme <name>`.
