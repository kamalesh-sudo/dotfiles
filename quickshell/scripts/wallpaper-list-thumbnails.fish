#!/usr/bin/env fish

# wallpaper-list-thumbnails.fish
#
# Lists wallpapers in ~/Pictures/Wallpapers, printing per line:
#   <original path>\t<cached thumbnail path>
#
# Images: resized copy via magick/convert.
# Videos: frame extracted with ffmpeg.
# Both cached in ~/.cache/quickshell-rice/wallpaper-thumbnails/,
# named by path hash — only regenerated if missing.

set -l WALL_DIR "$HOME/Pictures/Wallpapers"
set -l script_dir (cd -- (dirname (status --current-filename)); and pwd)
source "$script_dir/paths.fish"
set -l THUMB_DIR $QS_WALLPAPER_THUMBNAILS
mkdir -p "$THUMB_DIR"; or exit $status

set -l RESIZE_CMD
if type -q magick
  set RESIZE_CMD magick
else if type -q convert
  set RESIZE_CMD convert
else
  set RESIZE_CMD ""
end

set -l HAVE_FFMPEG 0
if type -q ffmpeg
  set HAVE_FFMPEG 1
end

find "$WALL_DIR" -maxdepth 1 -type f \
  \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \
     -o -iname '*.mp4' -o -iname '*.mkv' -o -iname '*.webm' -o -iname '*.mov' \) \
  | sort | while read -l f

    set -l hash (printf '%s' "$f" | md5sum | cut -d' ' -f1)
    set -l thumb "$THUMB_DIR/$hash.png"

    if not test -s "$thumb"
      set -l lower_path (string lower -- "$f")
      if string match -q -r '\.(mp4|mkv|webm|mov)$' -- "$lower_path"
        if test "$HAVE_FFMPEG" = 1
          ffmpeg -y -ss 1 -i "$f" -frames:v 1 -vf "scale=244:-1" \
            -loglevel error "$thumb" 2>/dev/null; or true
        end
      else if test -n "$RESIZE_CMD"
        "$RESIZE_CMD" "$f" -resize "244x132>" "$thumb" 2>/dev/null; or true
      end
    end

    if test -s "$thumb"
      printf '%s\t%s\n' "$f" "$thumb"
    else
      printf '%s\t%s\n' "$f" "$f"
    end
  end
