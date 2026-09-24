#!/usr/bin/env fish

cd -- $HOME
set -l SCRIPT_DIR (cd -- (dirname (status --current-filename)); and pwd)

# Keep Yahpax Quickshell runtime and component caches separate from other
# Quickshell shells running under the same user account.
set -gx XDG_CACHE_HOME "$HOME/.cache/yahpax"
set -gx PYWAL_CACHE_DIR "$XDG_CACHE_HOME/wal"
set -l RUNTIME_DIR "$HOME/.cache/yahpax/runtime"
mkdir -p "$RUNTIME_DIR"

if type -q awww-daemon; and not pgrep -x awww-daemon >/dev/null 2>&1
    awww-daemon >/dev/null 2>&1 &
    set -l awww_pid $last_pid
    printf '%s\n' "$awww_pid" > "$RUNTIME_DIR/awww-daemon.pid"
end

if type -q awww
    for retry in (seq 1 20)
        timeout 0.5s awww query >/dev/null 2>&1; and break
        sleep 0.25
    end
end

if test -x "$SCRIPT_DIR/scripts/restore-wallpaper.fish"
    "$SCRIPT_DIR/scripts/restore-wallpaper.fish" &
end

if type -q wl-paste; and type -q cliphist
    pgrep -f '[w]l-paste --type text --watch cliphist store' >/dev/null 2>&1; or \
        begin
            wl-paste --type text --watch cliphist store >/dev/null 2>&1 &
            printf '%s\n' "$last_pid" > "$RUNTIME_DIR/wl-paste-text.pid"
        end
    pgrep -f '[w]l-paste --type image --watch cliphist store' >/dev/null 2>&1; or \
        begin
            wl-paste --type image --watch cliphist store >/dev/null 2>&1 &
            printf '%s\n' "$last_pid" > "$RUNTIME_DIR/wl-paste-image.pid"
        end
end

exec qs -p "$SCRIPT_DIR"
