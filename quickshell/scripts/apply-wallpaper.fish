#!/usr/bin/env fish

# apply-wallpaper.fish <image-or-video> [transition-type] [transition-pos]
# Video: extracts a still frame so pywal always runs on a valid image.
# One path (apply-wallpaper-colors-only.fish) propagates the palette
# to kitty, Hyprland, qutebrowser, and zsh either way.
#
# [transition-type]/[transition-pos] are optional and used by the
# BarMorph wallpaper picker to make the awww "grow" transition start
# from the same point on screen where the bar was, instead of the
# screen center. Omitting them keeps the default awww/swww transition.

if test (count $argv) -lt 1
    echo "Usage: apply-wallpaper.fish <image-or-video> [transition-type] [transition-pos]" >&2
    exit 1
end

set -l input $argv[1]
set -l transition_type ""
set -l transition_pos ""
if test (count $argv) -ge 2
    set transition_type $argv[2]
end
if test (count $argv) -ge 3
    set transition_pos $argv[3]
end
set -l script_dir (cd -- (dirname (status --current-filename)); and pwd)
source "$script_dir/paths.fish"
set -l cache_dir $QS_RICE_CACHE
mkdir -p "$cache_dir"

if not test -f "$input"
    echo "File not found: $input" >&2
    exit 1
end

set -l mime (file --brief --mime-type -- "$input")
set -l palette_image "$input"
set -l video_mode 0

if string match -q 'video/*' "$mime"
    if not type -q mpvpaper
        echo "mpvpaper is required for video wallpapers; refusing to start a broken video path" >&2
        exit 1
    end
    if not type -q ffmpeg
        echo "ffmpeg is required for video wallpapers" >&2
        exit 1
    end

    # unique filename per run (nanosecond timestamp), not a fixed one —
    # pywal seems to cache the color scheme by the INPUT PATH rather than
    # content, so reusing the same path for different videos would make
    # it reuse the old video's colors even with a new frame written there
    set -l frame_stamp (date +%s%N)
    set palette_image "$cache_dir/wallpaper-frame-$frame_stamp.png"

    if not timeout 30s ffmpeg -hide_banner -loglevel error -y \
        -ss 00:00:01 -i "$input" -frames:v 1 "$palette_image"
        rm -f "$palette_image"
        echo "Failed to extract a palette frame from video: $input" >&2
        exit 1
    end
    if not test -s "$palette_image"
        echo "Video frame extraction produced no image: $input" >&2
        exit 1
    end

    find "$cache_dir" -maxdepth 1 -name 'wallpaper-frame-*.png' ! -name (basename "$palette_image") -delete 2>/dev/null; or true
    set video_mode 1
else if string match -q 'image/*' "$mime"
    pkill -x mpvpaper 2>/dev/null; or true
    set -l awww_extra_args
    if test -n "$transition_type"
        set -a awww_extra_args --transition-type "$transition_type" --transition-duration 0.9
        if test -n "$transition_pos"
            set -a awww_extra_args --transition-pos "$transition_pos"
        end
    end
    if type -q awww
        awww img $awww_extra_args "$input"
    else if type -q swww
        swww img $awww_extra_args "$input"
    end
else
    echo "Unsupported format: $mime" >&2
    exit 1
end

if not type -q wal
    echo "pywal (wal) not found" >&2
    exit 1
end

if test -n "$palette_image"
    set -l safe_name (string replace -a / _ -- "$palette_image")
    find "$HOME/.cache/wal/schemes" -maxdepth 1 -type f -name "$safe_name*" -delete 2>/dev/null; or true
end
wal -n -q -i "$palette_image"

if not test -s "$QS_WAL_COLORS"
    echo "pywal did not generate colors.json" >&2
    exit 1
end

printf '%s\n%s\n' "$input" "$mime" > "$cache_dir/current-wallpaper"
printf '%s\n' "$palette_image" > "$cache_dir/current-palette-image"

"$script_dir/apply-wallpaper-colors-only.fish" "$QS_WAL_COLORS" "$palette_image"

if test "$video_mode" = 1
    pkill -x mpvpaper 2>/dev/null; or true
    set -l mpvpaper_log "$cache_dir/mpvpaper.log"
    set -l mpv_options "no-audio loop-file=inf hwdec=auto-safe framedrop=vo video-sync=display-resample interpolation=no cache=no"
    setsid mpvpaper -o "$mpv_options" '*' "$input" >"$mpvpaper_log" 2>&1 &
    set -l mpvpaper_pid $last_pid
    sleep 0.25
    if not kill -0 "$mpvpaper_pid" 2>/dev/null; and not pgrep -x mpvpaper >/dev/null 2>&1
        echo "mpvpaper failed to start; see $mpvpaper_log" >&2
        exit 1
    end
end

echo "OK: wallpaper applied, colors propagated (kitty/Hyprland/qutebrowser/zsh)."

set -l STATE_FILE $QS_CURRENT_WALLPAPER
set -l IMG (sed -n '1p' "$STATE_FILE")
cp "$IMG" ~/.cache/quickshell-rice/current
