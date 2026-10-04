#!/usr/bin/env fish

set -l script_dir (cd -- (dirname (status --current-filename)); and pwd)
set -l source_root (dirname (dirname $script_dir))
set -l target_root "$HOME/.config"
set -l state_dir "$HOME/.local/state/yahpax"
set -l manifest "$state_dir/install-manifest"

set -l required fish qs Hyprland hyprlock awww awww-daemon wal wl-copy wl-paste cliphist cava pipewire wireplumber gpu-screen-recorder kitty qutebrowser nvim fastfetch starship nmcli python3 ffmpeg magick hyprctl systemctl mpvpaper
set -l missing

for command_name in $required
    if not type -q $command_name
        set -a missing $command_name
    end
end

if test (count $missing) -gt 0
    echo "Missing required commands:"
    for command_name in $missing
        echo "  $command_name"
    end
    echo "Install them with your distribution's package manager, then run this script again."
    exit 1
end

if test -e "$manifest"
    echo "An install manifest already exists: $manifest"
    echo "Run uninstall.fish first if you want to reinstall."
    exit 1
end

set -l names hypr fish kitty fastfetch
for name in $names
    set -l source "$source_root/$name"
    set -l target "$target_root/$name"
    if not test -e "$source"
        echo "Missing source path: $source" >&2
        exit 1
    end
end
set -l quickshell_source "$source_root/quickshell/yahpax"
if not test -e "$quickshell_source"
    echo "Missing source path: $quickshell_source" >&2
    exit 1
end
if not test -f "$source_root/starship.toml"
    echo "Missing source path: $source_root/starship.toml" >&2
    exit 1
end

mkdir -p "$state_dir"
set -l entries "$source_root/hypr" "$source_root/fish" "$source_root/kitty" "$source_root/fastfetch" "$quickshell_source" "$source_root/starship.toml"
set -l targets "$target_root/hypr" "$target_root/fish" "$target_root/kitty" "$target_root/fastfetch" "$target_root/quickshell/yahpax" "$target_root/starship.toml"

for i in (seq (count $entries))
    set -l source $entries[$i]
    set -l target $targets[$i]

    if test "$source" = "$target"
        continue
    end

    if test -L "$target"; and test (readlink "$target") = "$source"
        continue
    end

    set -l backup "$target.rice.bak"
    set -l suffix 1
    while test -e "$backup"; or test -L "$backup"
        set backup "$target.rice.bak.$suffix"
        set suffix (math $suffix + 1)
    end

    if test -e "$target"; or test -L "$target"
        mv "$target" "$backup"
    end

    ln -s "$source" "$target"
    printf '%s\t%s\t%s\n' "$target" "$source" "$backup" >> "$manifest"
end

chmod +x "$source_root/quickshell/scripts"/*.fish

echo "Rice installed with symlinks."
echo "Backups are recorded in: $manifest"
echo "Start or log into Hyprland to run the setup."
