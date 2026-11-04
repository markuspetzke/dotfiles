# Hyprland

Lua configuration for Hyprland 0.57, started through uwsm. The profile comes from
`HYPR_PROFILE` (`desktop` or `laptop`) or from battery detection: a system battery
means `laptop`, anything else `desktop` (`scripts/hypr-profile.sh`).

To force a profile, add `export HYPR_PROFILE=laptop` to `~/.config/uwsm/env`.
The other session variables live there as well.

## Key bindings

| Keys | Action |
| --- | --- |
| `Super+Escape` | Lock the screen |
| `Super+H/J/K/L` | Focus left/down/up/right |
| `Super+Shift+H/J/K/L` | Move window |
| `Super+Ctrl+H/J/K/L` | Resize window |
| `Super+1..4` / `Super+Shift+1..4` | Switch workspace / move window there |
| `Super+Return` | Swap window with master |
| `Super+Ctrl+F1` | Laptop: internal display only |
| `Super+Ctrl+F2` | Laptop: extend to external displays on the right |
| `Super+Ctrl+F3` | Laptop: mirror internal display to external ones |
| Release `Super` | Launcher |
| `Super+V` | Clipboard history |
| `Super+Shift+S` | Screenshot of an area to the clipboard |
| `Super+X` / `Shift` / `Ctrl` | Desktop: death counter +1 / -1 / 0 (stream) |
| `Super+C` | Desktop: save the last 60 s from the OBS replay buffer |

`Alt+Arrow keys` and `Alt+H/J/K/L` stay free for applications.
On the Neo65, `Super+code:49` also locks, as a fallback for QMK Grave-Escape.

## Laptop monitors

A new laptop login starts with the extended profile. The choice is stored in
`~/.config/hypr/.monitor-profile` and survives restarts. It also applies to newly
connected displays.
The internal display (`eDP-1`) stays active in every profile, unless the lid is closed
while docked (see Lid). If the laptop uses a different connector name, adjust it in
`monitors.lua`.
The desktop layout with DP-2/DP-3 is configured separately.

### Lid

`systemd-logind` decides whether the laptop sleeps or only locks. The drop-in file is
`hypr/logind/laptop.conf`. Install it once on the laptop; it takes effect after a
reboot (`theme-setup --check` reports if it is missing):

```sh
sudo install -Dm644 ~/.config/hypr/logind/laptop.conf /etc/systemd/logind.conf.d/90-hypr-laptop.conf
```

| State | logind | Hyprland (`monitors.lua`) |
| --- | --- | --- |
| Battery | suspend | - |
| AC power | lock | internal panel off |
| Docked (external monitor) | nothing | `eDP-1` disabled, everything on the external monitors |

Opening the lid turns `eDP-1` back on. If hibernation is set up, the file can use
`suspend-then-hibernate` instead of `suspend`.

### Idle

| Time | Desktop (`hypridle.conf`) | Laptop (`hypridle-laptop.conf`) |
| --- | --- | --- |
| 5 min | - | dim to 10 %, keyboard backlight off |
| 9 min | theme screensaver | theme screensaver |
| 10 min | lock | lock |
| 10.5 min | monitors off | monitors off |
| 15 min | - | on battery: sleep |
| 60 min | suspend | sleep, also on AC power |

Locking happens before the monitors turn off, so hyprlock gets a real screenshot as its
background. Sleep on the laptop means `suspend-then-hibernate` if hibernation is set up,
otherwise suspend (`scripts/idle-sleep.sh`).

While audio or video plays, `media-watch.service` holds an idle inhibitor
(`systemd-inhibit --what=idle`). No stage fires then, and the chain starts over once
playback ends. A condition inside `on-timeout` is not enough for this: hypridle runs
each stage only once per idle period.

Before suspending, hypridle asks `scripts/sleep-allowed.sh` whether a program blocks
sleep (e.g. `backup-hetzner.service`) and retries every 5 minutes. Locking and turning
the monitors off still happen. `idle-test` runs the chain with short timeouts.

### Automatic monitors and power profiles

On laptops, startup picks `mobile` (`eDP-1` only) or `extended` (external monitor on the
right) automatically. Monitor hotplug switches between them as well; the manual
`Super+Ctrl+F1/F2/F3` shortcuts remain available. `presentation` is a manual override.

`power-profile.service` runs only in the laptop profile and picks `balanced` on AC
power and `power-saver` on battery. `scripts/power-source.sh` detects AC or battery
(including USB-C charging). It needs `power-profiles-daemon`:

```sh
sudo pacman -S power-profiles-daemon
sudo systemctl enable --now power-profiles-daemon
```

Without the package the service stays inactive and changes nothing.

### Services

Waybar, hypridle, hyprpaper, hyprsunset, dunst, both clipboard watchers and
`media-watch` run as user services under `systemd --user`. At startup Hyprland only
runs `uwsm finalize`; once uwsm reports the session as ready,
`graphical-session.target` starts `hypr-session.target` and with it all services.
The services hang off the target only through `Wants=`.

Once per machine (`bin/theme-setup` does this):

```sh
systemctl --user enable hypr-session.target
```

After installing or changing units:

```sh
systemctl --user daemon-reload
systemctl --user restart hypr-session.target
systemctl --user status hypr-session.target
```

Logs: `journalctl --user -u hypridle -u waybar -u hyprpaper -f`.
The services have memory/process limits and run with reduced privileges. The packaged
units of dunst and hyprpolkitagent get the same rules through user drop-ins in
`systemd/user/*.service.d/`.

Because of `NoNewPrivileges` and the limits, everything a service starts inherits these
restrictions (e.g. `sudo` does not work there). Programs started from Waybar, dunst, the
launcher or a key binding therefore run through `uwsm-app --` as their own unit.
`uwsm-app` is uwsm's fast client (~10 ms instead of ~90 ms) and talks to
`wayland-wm-app-daemon.service`, which starts with the session.
`hypridle.service` deliberately has no sandbox options at all: hyprlock needs the setuid
program `unix_chkpwd` to check the password, and in user units both `NoNewPrivileges`
(also implied by `LockPersonality`, `RestrictSUIDSGID`, `RestrictRealtime`) and the
namespace options (`PrivateTmp`, `ProtectSystem`, `ProtectKernel*`,
`ProtectControlGroups`) block that.

### Waybar status

On the right, Waybar also shows the power profile (built-in `power-profiles-daemon`
module, no polling) and the idle inhibitor. Clicking the power profile switches to the
next profile, right-clicking to the previous one. Battery, audio, network and the other
system indicators depend on the desktop or laptop profile.

## Night light

`hyprsunset.conf` switches to 4500 K at 21:00 and back to unchanged daylight colors at
07:30. Brightness and gamma stay at 100 %. It starts through `hyprsunset.service`
(`scripts/run-hyprsunset.sh`).

`scripts/run-hyprsunset.sh` uses the package (`sudo pacman -S hyprsunset`) and only falls
back to a copy in `~/.local/bin/hyprsunset`, which gets no updates.

- `hyprctl hyprsunset identity`: normal colors until the next profile change.
- `hyprctl hyprsunset temperature 4500`: warm colors right away.

## Scripts

Helpers in `scripts/`, started by services, key bindings or hypridle:

| Script | Purpose |
| --- | --- |
| `hypr-profile.sh` | prints the hardware profile (`desktop`/`laptop`): `HYPR_PROFILE`, otherwise a system battery decides |
| `run-waybar.sh`, `run-hypridle.sh` | Waybar and hypridle with the config of the profile (`waybar.service`, `hypridle.service`) |
| `run-hyprsunset.sh` | night light (`hyprsunset.service`), see above |
| `run-power-profile.sh` | laptop only: `power-saver` on battery, `balanced` on AC (`power-profile.service`) |
| `power-source.sh` | prints `ac` or `battery` (also when charging over USB-C) |
| `media-watch.sh` | holds an idle inhibitor while media plays and runs `video-tags` (`media-watch.service`) |
| `sleep-allowed.sh` | hypridle `condition_cmd`: no suspend while a program blocks sleep |
| `idle-sleep.sh` | laptop: suspend-then-hibernate if hibernation is set up, plain suspend otherwise |
| `backlight.sh` | laptop idle: dim to 10 % and turn the keyboard backlight off, restore on activity |
| `lock-media.sh` | current track on the lock screen |
| `waybar-headset.sh` | Waybar: battery level of the Arctis 7 (headsetcontrol) |
| `screenshot.sh` | screenshot of an area (`Super+Shift+S`) to the clipboard; `file` also saves it to `~/Pictures/Screenshots` |
| `clipboard.sh` | clipboard history (`Super+V`): pick an entry from cliphist in the launcher |

## Editing

`.luarc.json` points the Lua language server to the API stubs of the hyprland package
(`/usr/share/hypr/stubs`, Lua 5.5): completion, docs and checks for `hl.*` in Neovim.

## Checks

`dotfiles-check` checks the whole repo and also runs before every commit. For Hyprland
alone: `hyprctl reload` reloads the configuration, `hyprctl configerrors` shows errors.
`Hyprland --verify-config` crashes with the Lua config (0.57) and is not usable for this.
