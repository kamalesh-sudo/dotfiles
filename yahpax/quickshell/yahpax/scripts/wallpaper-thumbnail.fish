#!/usr/bin/env fish
# wallpaper-thumbnail.fish <video>
#
# Generates (with caching) a PNG thumbnail for a video and prints the
# path to stdout. Cached by path+mtime hash in
# ~/.cache/yahpax/rice/wallpaper-thumbs/ — ffmpeg only runs once
# per file; subsequent calls are just a stat + md5sum.

if test (count $argv) -lt 1; or test -z "$argv[1]"
    echo "Usage: wallpaper-thumbnail.fish <video>" >&2
    exit 1
end

set -l SRC $argv[1]
if not test -f "$SRC"
    exit 1
end

set -l script_dir (cd -- (dirname (status --current-filename)); and pwd)
source "$script_dir/paths.fish"
set -l THUMB_DIR $QS_VIDEO_THUMBS
mkdir -p "$THUMB_DIR"; or exit $status

set -l MTIME (stat -c %Y "$SRC")
or exit $status
set -l HASH (printf '%s|%s' "$SRC" "$MTIME" | md5sum | cut -d' ' -f1)
set -l OUT "$THUMB_DIR/$HASH.png"

if not test -s "$OUT"
    ffmpeg -y -ss 1 -i "$SRC" -frames:v 1 -vf "scale=440:-1" -update 1 "$OUT" >/dev/null 2>&1
    or ffmpeg -y -i "$SRC" -frames:v 1 -vf "scale=440:-1" -update 1 "$OUT" >/dev/null 2>&1
    or exit 1
end

if test -s "$OUT"
    printf '%s\n' "$OUT"
end
