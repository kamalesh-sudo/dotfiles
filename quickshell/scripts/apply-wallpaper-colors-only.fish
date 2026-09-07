#!/usr/bin/env fish

set -l script_dir (cd -- (dirname (status --current-filename)); and pwd)
source "$script_dir/paths.fish"

set -l colors_json $QS_WAL_COLORS
if test (count $argv) -ge 1; and test -n "$argv[1]"
    set colors_json $argv[1]
end

set -l palette_image
if test (count $argv) -ge 2; and test -n "$argv[2]"
    set palette_image $argv[2]
else
    set palette_image (cat "$QS_CURRENT_PALETTE" 2>/dev/null; or cat "$HOME/.cache/wal/wal" 2>/dev/null; or true)
end

if not test -s "$colors_json"
    echo "missing colors.json: $colors_json" >&2
    exit 1
end

python3 "$script_dir/apply-starship-colors.py" "$colors_json"; or exit $status

fish "$script_dir/write-hypr-theme.fish" "$colors_json"; or exit $status

if test -d (dirname "$QS_KITTY_CONFIG"); or test -f "$QS_KITTY_CONFIG"
    python3 "$script_dir/apply-kitty-colors.py" "$colors_json" "$QS_KITTY_CONFIG"; or exit $status
end

if test -d "$HOME/.config/qutebrowser"
    python3 "$script_dir/apply-qutebrowser-colors.py" "$colors_json" "$HOME/.config/qutebrowser"; or exit $status
    python3 "$script_dir/apply-qutebrowser-startpage.py" "$colors_json" "$palette_image" "$HOME/.config/qutebrowser"; or exit $status
end

if test -d "$QS_FASTFETCH_CONFIG"; or test -f "$QS_FASTFETCH_CONFIG/config.jsonc"
    python3 "$script_dir/apply-fastfetch-colors.py" "$colors_json" "$QS_FASTFETCH_CONFIG"; or exit $status
end

python3 -c '
import json, sys
c = json.load(open(sys.argv[1]))["colors"]

def to256(hexcolor):
    h = hexcolor.lstrip("#")
    r, g, b = int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16)
    return 16 + 36 * round(r / 255 * 5) + 6 * round(g / 255 * 5) + round(b / 255 * 5)

pairs = [("RICE_COL_ACCENT", c["color4"]), ("RICE_COL_MUTED", c["color8"]),
         ("RICE_COL_OK", c["color2"]), ("RICE_COL_ERROR", c["color1"])]
with open(sys.argv[2], "w") as f:
    for key, color in pairs:
        f.write("typeset -g %s=%d\n" % (key, to256(color)))
' "$colors_json" "$HOME/.cache/wal/colors-zsh.sh"
or exit $status

echo "colors propagated: Hyprland, kitty, qutebrowser, zsh, fastfetch"
