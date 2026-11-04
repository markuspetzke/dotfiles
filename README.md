# Dotfiles

Hyprland desktop on Arch Linux with switchable themes. One branch for desktop and laptop:
whatever differs (monitors, battery, idle, lid) is detected at runtime by
`hypr/scripts/hypr-profile.sh`.

## Themes

`theme <name>` switches everything at once: Hyprland, Waybar, Kitty, Neovim, Dunst, lock
screen, launcher, wallpaper (by time of day), cursor, sounds, screensaver, browser and login
screen. Details: [themes/README.md](themes/README.md).

| | |
| --- | --- |
| ![wired](docs/screenshots/wired.webp) **wired**: Lain, phosphor green and violet, terminal bar, power pole | ![retro](docs/screenshots/retro.webp) **retro**: amber CRT, warm black, cream, amber |
| ![win31](docs/screenshots/win31.webp) **win31**: Windows 3.1, teal desktop, system gray, DOS terminal | ![winxp](docs/screenshots/winxp.webp) **winxp**: Windows XP (Luna), taskbar at the bottom, own start menu |
| ![office](docs/screenshots/office.webp) **office**: The Office, rooms as workspaces, quitting-time counter, quotes | ![tokyonight](docs/screenshots/tokyonight.webp) **tokyonight**: rounded corners, blur, pill bar |

The screenshots show the themes with my own images, logos and sounds (e.g. Bliss and the
XP logos). These files live in each theme's `private/` folder and are not part of the repo;
without them every theme falls back to its own drawings. What goes where:
`themes/winxp/PRIVATE.md`, `themes/office/PRIVATE.md` and, for wallpapers,
`themes/README.md`.

## Layout

| Folder | Contents |
| --- | --- |
| `hypr/` | Hyprland (Lua config), hypridle, hyprlock, laptop profile: [hypr/README.md](hypr/README.md) |
| `themes/` | the themes, one folder each with the same set of files |
| `waybar/`, `kitty/`, `dunst/`, `fastfetch/` | bar, terminal, notifications, system info |
| `nvim/` | Neovim with lazy.nvim: [nvim/README.md](nvim/README.md) |
| `bin/` | own scripts (`theme`, `theme-setup`, `backup-check`, `dotfiles-check`, ...): [bin/README.md](bin/README.md) |
| `systemd/user/` | Hyprland session services, backups, timers |
| `bash/`, `git/` | shell and git defaults |
| `uwsm/env`, `pacman/makepkg.conf`, `gtk-3.0/gtk.css` | session variables, AUR builds on all threads, Thunar styling |

`.gitignore` is a whitelist: everything else in `~/.config` stays out of the repo.

## Setup

Requires Arch Linux with Hyprland 0.57 and uwsm. `bin/theme-setup --check` lists missing
programs.

```sh
cd ~/.config
git init -b master
git remote add origin git@github.com:markuspetzke/dotfiles.git
git fetch origin
git checkout -f -t origin/master   # overwrites files with the same name in ~/.config
bin/theme-setup                    # scripts, bash, font, services, theme; reports what is missing
```

## Checks

Before every commit `bin/dotfiles-check` checks Lua, shell, Python, JSON, systemd units and the
running Hyprland config (git hook in `.githooks/`, enabled by `theme-setup`). That way no
broken config reaches another machine. Run it by hand with `dotfiles-check`.
