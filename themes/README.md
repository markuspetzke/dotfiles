# Themes

Jedes Theme ist ein Ordner mit denselben Dateien. Die eigentlichen Configs binden
nur das aktive Theme ein: `~/.config/theme-current` -> `themes/<name>`.
Der Symlink ist nicht im Git, jeder Rechner hat sein eigenes Theme.

```sh
theme            # Liste, aktives mit *
theme wired      # umschalten und alles neu laden
```

Nach einem frischen Clone (z. B. Laptop) einmal `~/.config/bin/theme-setup` ausfuehren:
Schrift, Skripte, Timer, Launcher und Theme in einem Schritt.

Auf dem Laptop (Profil `laptop`) sind Shader und umlaufender Rahmen standardmaessig aus
(Akku); `Super+Shift+G` schaltet den Shader bei Bedarf ein.

| Theme | Stil |
| --- | --- |
| `tokyonight` | Das Setup von vor den Retro-Themes: runde Ecken, Blur, Schatten, Pill-Leiste, FiraCode |
| `winxp` | Windows XP (Luna): blaue Taskleiste mit gruenem Startknopf, Huegel-Wallpaper, gelbe Sprechblasen, dunkle Konsole |
| `office` | The Office (Dunder Mifflin Scranton), dunkel: Raeume als Workspaces, Feierabend-Zaehler, Zitate, Memo, Stempeluhr, World's-Best-Boss-Tasse |
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
| `greeter.toml` | Farben des Anmeldebildschirms (sysc-greet); einmalig `sudo ~/.config/bin/greeter-setup` | alle |
| `thunar.css` | Thunar-Fenster (eingebunden ueber `gtk-3.0/gtk.css`); Thunar liest es nur beim Start, `theme` beendet einen Thunar ohne offene Fenster | alle |
| `(private/)icon-theme/<Name>/` | Symbol-Theme (gsettings), z. B. XP-Ordner in Thunar; sonst Adwaita | winxp |
| `themes/spicetify/color.ini` (Abschnitt `[<name>]`) | Spotify-Farben ueber Spicetify (Theme `DesktopTheme`); wirkt nach Spotify-Neustart | alle |
| `hyprtoolkit.conf` | Symlink `hypr/hyprtoolkit.conf` (Launcher) |
| `dunst.conf` | Symlink `dunst/dunstrc.d/50-theme.conf` |
| `fastfetch.jsonc`, `fastfetch-logo.txt` | Symlink `fastfetch/config.jsonc` |
| `nvim.lua` | `nvim/lua/config/theme.lua` (Colorscheme, gruvbox-Overrides, Highlights) |
| `wallpaper.png`, `wallpaper.py` | `bin/theme-wallpaper` -> `~/.local/state/theme/wallpaper.png` (hyprpaper, Hyprlock); `wallpaper.py` erzeugt die Bilder |

## Optionale Extras

| Datei | Wirkung | Themes |
| --- | --- | --- |
| `shader.frag` | Bildschirm-Shader; `Super+Shift+G` an/aus, in Vollbild-Spielen automatisch aus | retro (Scanlines, leichter Bernstein-Stich), wired (Roehre) |
| `palette.lua`: `border_gradient`, `border_loop` | Verlaufsrahmen (optional umlaufend) | tokyonight, winxp, wired (umlaufend) |
| `palette.lua`: `config`, `animations`, `window_rules` | ueberschreibt Hyprland-Einstellungen aus `hypr/hyprland.lua` (Theme wird zuletzt geladen) | tokyonight (Rundung, Blur, Schatten, transparentes Kitty), office (Rundung, Schatten) |
| `nvim.lua`: `background` | helles oder dunkles Neovim (Standard: dunkel) | (derzeit keins hell) |
| `wallpaper-rotate` + `wallpapers/*.png` | Wallpaper der Reihe nach wechseln (Intervall in Sekunden) | tokyonight (stuendlich) |
| `wallpaper-phases` + `wallpapers/<phase>.png` | Wallpaper nach Uhrzeit (`theme-wallpaper.timer`, alle 10 min) | winxp (Tag/Abend/Nacht), office (Tag/Abend/Nacht), retro (Sonne wandert), wired (Tag/Daemmerung/Nacht) |
| `sounds/{notify,lock,unlock}.wav` (+ `sounds.py`), optional `critical`, `startup`, `shutdown` | Klaenge bei Benachrichtigung (dunst; `critical` bei hoher Dringlichkeit), Sperren/Entsperren (`bin/theme-lock`), Sitzungsstart (`theme --session`) und Ausschalten im Startmenue; eigene Dateien in `private/sounds/` haben Vorrang | winxp (Pling, Akkord), office (Telefon, Stempel, Tippen + Ding), retro (Relais, Roehre an/aus), wired (Modem), win31 (Glocke, Akkord) |
| `cursor/<Name>/` (+ `cursor.py`) | eigener Mauszeiger-Pfeil, Rest geerbt vom Wii-Zeiger | winxp (Pfeil mit Schatten), office (weisser Pfeil), retro (Bernstein-Pfeil), wired (Fadenkreuz), win31 (Pfeil) |
| `screensaver.py` | Bildschirmschoner nach 9 min (`bin/screensaver`, hypridle) | winxp (Rohre), office (Konferenzraum-Notiz), retro (wandernde Uhr), wired (Hex-Regen), win31 (Sternenfeld) |
| `nvim.lua`: `dashboard_header` | Kopf des Neovim-Startbildschirms | winxp (Fenster "Willkommen"), office (Memo), retro (Sonne + READY.), wired, win31 |
| `browser.json` | Farben fuer Helium; `bin/theme-browser` baut daraus `~/.local/share/theme-browser` (einmalig als entpackte Erweiterung laden, siehe `bin/theme-browser`; wirkt nach Helium-Neustart) | alle |
| `hyprtoolkit.conf` | Launcher (hyprlauncher); `theme` startet den Daemon neu | alle |
| `startmenu.py` | eigenes Startmenue statt hyprlauncher (Super-Taste, Startknopf; `bin/menu`) | winxp (XP-Startmenue) |
| `kitty-scanlines.png` | Scanline-Textur im Terminal | wired |
| `kitty.conf`: `cursor_trail` | Phosphor-Nachleuchten hinter dem Cursor | retro |
| `waybar-modules.jsonc` | eigene Modul-Formate, z. B. Segmentbalken `CPU ▮▮▯▯▯` (retro), Textlabels (wired) | retro, wired, office (Workspaces als Raeume, Feierabend-Zaehler) |

Die Generatoren (`wallpaper.py`, `sounds.py`, `cursor.py`) erzeugen die Dateien neu, z. B.
nach Farbaenderungen: `python3 themes/wired/wallpaper.py`.

Neues Theme: Ordner kopieren, Farben anpassen, `theme <name>`.
