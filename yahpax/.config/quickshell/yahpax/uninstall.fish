#!/usr/bin/env fish

set -l script_dir (cd -- (dirname (status --current-filename)); and pwd)
set -l state_dir "$HOME/.local/state/yahpax"
set -l manifest "$state_dir/install-manifest"

if not test -f "$manifest"
    echo "No rice install manifest found; nothing to uninstall."
    exit 0
end

for line in (cat "$manifest")
    set -l fields (string split \t -- "$line")
    if test (count $fields) -ne 3
        echo "Skipping malformed manifest entry." >&2
        continue
    end

    set -l target $fields[1]
    set -l source $fields[2]
    set -l backup $fields[3]

    if test -L "$target"; and test (readlink "$target") = "$source"
        rm "$target"
        echo "Removed $target"
    else
        echo "Left changed path untouched: $target"
        continue
    end

    if test -e "$backup"; or test -L "$backup"
        mv "$backup" "$target"
        echo "Restored $target"
    end
end

rm "$manifest"
rmdir "$state_dir" 2>/dev/null; or true
echo "Rice configuration links removed. System packages were not changed."
