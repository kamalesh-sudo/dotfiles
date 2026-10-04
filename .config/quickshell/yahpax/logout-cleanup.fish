#!/usr/bin/env fish

# Stop only processes whose PIDs were recorded by Yahpax itself.
# Persistent wallpaper/theme caches are intentionally retained.
set -l runtime_dir "$HOME/.cache/yahpax/runtime"

for entry in \
    "awww-daemon|awww-daemon.pid" \
    "mpvpaper|mpvpaper.pid"
    set -l fields (string split '|' -- "$entry")
    set -l process_name $fields[1]
    set -l pid_file "$runtime_dir/$fields[2]"

    if not test -s "$pid_file"
        continue
    end

    set -l pid (string trim (cat "$pid_file" 2>/dev/null))
    if string match -rq '^[0-9]+$' -- "$pid"
        set -l actual_name (string trim (cat "/proc/$pid/comm" 2>/dev/null))
        if test "$actual_name" = "$process_name"
            kill "$pid" 2>/dev/null; or true
        end
    end
    rm -f -- "$pid_file"
end
