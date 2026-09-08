# Hyprland Quickshell rice

A Hyprland + Quickshell desktop rice with a themed bar, dock, wallpaper pipeline, launcher, clipboard history, notifications, Wi-Fi menu, and desktop visuals.

## Dependencies

Fish, Quickshell (`qs`), Hyprland, `hyprlock`, `awww`/`awww-daemon`, Pywal (`wal`), PipeWire, WirePlumber, `wl-copy`/`wl-paste`, `cliphist`, Cava, GPU Screen Recorder, Kitty, Qutebrowser, Neovim, Burp Suite, Fastfetch, Starship, NetworkManager (`nmcli`), Python 3, FFmpeg, ImageMagick (`magick`), `mpvpaper` for video wallpapers, `hyprctl`, and `systemctl`.

`swww` and `convert` are optional fallbacks. Python uses only the standard library; no pip packages are required.

The scripts also require a normal POSIX `sh` and standard core utilities such as `cat`, `chmod`, `cp`, `cut`, `dirname`, `find`, `ln`, `md5sum`, `mkdir`, `mv`, `pgrep`, `pkill`, `readlink`, `rm`, `sed`, `seq`, `setsid`, `sleep`, `stat`, and `timeout`.

## Install

From the copied `.config/quickshell` directory:

```fish
fish install.fish
```

The installer creates symlinks so changes stay synchronized with the repository. Existing targets are backed up and never silently overwritten.

## Uninstall

```fish
fish uninstall.fish
```

Only links created by the installer are removed; recorded backups are restored. Packages are not removed.

## Keybinds

- `SUPER + SPACE` — app launcher
- `SUPER + V` — clipboard history
- `SUPER + N` — notifications
- `CTRL + ALT + DELETE` — power menu
- `SUPER + W` — wallpaper selector
- Wi-Fi — no dedicated Hyprland keybind; available through the `wifiMenu` IPC target
- `CTRL + R` — toggle partial screen recording
- `CTRL + SHIFT + R` — start partial screen recording
- `CTRL + SHIFT + X` — stop recording

This rice is built specifically for Hyprland and Quickshell; other compositors require configuration changes.
