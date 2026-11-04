# Dotfiles (~/.config)

Arch Linux, Hyprland 0.57 (Lua-Config) ueber uwsm, Waybar, Kitty, Dunst, Neovim (lazy.nvim).
Repo `markuspetzke/dotfiles` ist **oeffentlich**. Ein Branch (`master`) fuer Desktop und Laptop;
die Unterschiede erkennt `hypr/scripts/hypr-profile.sh` zur Laufzeit.
Doku, Kommentare und Commits auf Deutsch, ohne Umlaute (ae/oe/ue/ss).

## Was versioniert ist

`.gitignore` ist eine Whitelist (`*`, dann `!ordner/`). Neue Ordner/Dateien muessen dort
freigegeben werden, sonst landen sie nicht im Repo. Nie versioniert:
- `theme-current` (lokaler Symlink aufs aktive Theme, je Rechner)
- `themes/*/private/` (urheberrechtlich geschuetztes Material: Logos, Bilder, Sounds)
- `systemd/user/*.wants/`, `hypr/.monitor-profile`

## Aufbau

| Pfad | Inhalt |
| --- | --- |
| `hypr/` | `hyprland.lua` laedt `host.lua`, `binds.lua`, `monitors.lua`, `windowrule.lua`, zuletzt `theme.lua`. Siehe `hypr/README.md` |
| `hypr/scripts/` | Hilfsskripte, u. a. `hypr-profile.sh` (Profil `desktop`/`laptop`: `HYPR_PROFILE` oder Akku-Erkennung) |
| `themes/<name>/` | Desktop-Themes (retro, wired, win31, winxp, office, tokyonight). Dateien und Extras: `themes/README.md` |
| `bin/` | Eigene Skripte, nach `~/.local/bin` verlinkt. Uebersicht: `bin/README.md` |
| `waybar/` | `style.css` = Theme-Farben + `base.css` + Theme-Abweichungen; `config-{desktop,laptop}.jsonc` |
| `systemd/user/` | Session-Dienste (`hypr-session.target`), Backups, Timer |
| `uwsm/env` | Session-Variablen fuer Hyprland und alle systemd-Dienste |
| `nvim/` | Neovim-Config, siehe `nvim/README.md`; Theme kommt aus `themes/<name>/nvim.lua` |
| `bash/`, `git/` | `~/.bashrc` laedt nur `bash/bashrc`; `git/config` hat die Grundeinstellungen, Name/Mail und die GitHub-SSH-Umleitung bleiben lokal in `~/.gitconfig` |
| `.githooks/` | `pre-commit` ruft `bin/dotfiles-check --staged` (aktiv ueber `core.hooksPath`, setzt `theme-setup`) |
| `README.md`, `docs/` | Uebersicht fuer GitHub mit Screenshots je Theme |

## Themes

- Configs binden nur `~/.config/theme-current/...` ein. Umschalten: `theme <name>` (laedt alles neu).
- Neues Theme: Ordner kopieren, `palette.lua` muss existieren (daran erkennt `theme` ein Theme).
- Generierte Dateien (`wallpaper.png`, `sounds/`, `cursor/`) kommen aus `wallpaper.py`,
  `sounds.py`, `cursor.py` im Theme-Ordner: nach Farbaenderungen neu erzeugen, nicht von Hand bearbeiten.
- Bei neuen Theme-Dateien/Extras die Tabellen in `themes/README.md` mitpflegen, neue Skripte in `bin/README.md`.

## Arbeitsweise

- Aenderungen live pruefen (`hyprctl reload`, `theme <name>`, `hyprctl` / `journalctl --user`).
- Keinen Branch wechseln, waehrend Hyprland laeuft: fehlende Config -> Notfallmodus.
- Hyprland-Config nicht mit blockierenden Aufrufen bremsen; Langsames in Skripte auslagern
  (Beispiel `bin/video-tags`).
- Laptop-Profil beachten: dauernd neu zeichnende Effekte (Shader, umlaufender Rahmen) dort aus.
- hypridle fuehrt jede Stufe nur einmal pro Leerlauf aus. "Nicht waehrend X" daher nie als
  Bedingung im `on-timeout`, sondern als Idle-Sperre (`systemd-inhibit`, siehe `media-watch`)
  oder `condition_cmd` + `condition_retry`.
- Programme aus Binds/Waybar/dunst ueber `uwsm-app --` starten.
- Vor dem Commit `dotfiles-check` (laeuft auch als Hook). `Hyprland --verify-config` stuerzt mit
  der Lua-Config ab; fuer Hyprland `hyprctl configerrors` nutzen.
- Screenshots fuer `docs/`: mit `private/`-Inhalten (so nutzt der User die Themes), aber ohne
  Medientitel in der Leiste. Die `private/`-Dateien selbst kommen nie ins Repo.
- Commits nur unter dem Namen des Users, ohne Co-Authored-By-Zeile und ohne Hinweis auf Claude.
  Nicht pushen, das macht der User selbst.
- Schritte mit sudo (z. B. `bin/greeter-setup`) nicht selbst ausfuehren, sondern dem User nennen.
