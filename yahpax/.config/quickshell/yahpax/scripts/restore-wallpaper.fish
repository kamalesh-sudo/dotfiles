#!/usr/bin/env fish
# restore-wallpaper.fish
#
# Called by launch.fish at boot, after awww-daemon comes up. Reads the
# last real wallpaper saved by apply-wallpaper.fish and:
#   - if it's a video: reapplies everything (mpvpaper + pywal + colors),
#     since nothing else relaunches mpvpaper after a reboot;
#   - if it's an image: does nothing — awww-daemon restores it on its
#     own and colors are already persisted in colors-wal.lua/kitty.ini/zsh.

set -l SCRIPT_DIR (cd -- (dirname (status --current-filename)); and pwd)
source "$SCRIPT_DIR/paths.fish"
set -l STATE_FILE $QS_CURRENT_WALLPAPER

if not test -f "$STATE_FILE"
    exit 0
end

set -l IMG (sed -n '1p' "$STATE_FILE")
or exit $status
set -l TYPE (sed -n '2p' "$STATE_FILE")
or exit $status

if not test -n "$IMG"; or not test -f "$IMG"
    exit 0
end

if not test -n "$TYPE"
    set TYPE (file --brief --mime-type -- "$IMG")
end

if string match -q 'video/*' "$TYPE"
    exec "$SCRIPT_DIR/apply-wallpaper.fish" "$IMG"
else
    awww img "$IMG"
end
