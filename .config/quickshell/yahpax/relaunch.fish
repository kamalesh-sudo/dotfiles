#!/usr/bin/env fish

cd -- $HOME
set -l SCRIPT_DIR (cd -- (dirname (status --current-filename)); and pwd)
set -l runtime_dir /tmp
if set -q XDG_RUNTIME_DIR
    set runtime_dir $XDG_RUNTIME_DIR
end
set -l LOG_FILE "$runtime_dir/yahpax-quickshell.log"

# Stop all Quickshell processes so duplicate bars cannot survive.
pkill -TERM -x quickshell >/dev/null 2>&1; or true
pkill -TERM -x qs >/dev/null 2>&1; or true
sleep 0.8

# Force-clean any process that ignored the graceful signal.
pkill -KILL -x quickshell >/dev/null 2>&1; or true
pkill -KILL -x qs >/dev/null 2>&1; or true

# This is the dedicated Yahpax cache for this Quickshell setup.
rm -rf -- "$HOME/.cache/yahpax/quickshell"
rm -f -- "$LOG_FILE"

nohup "$SCRIPT_DIR/launch.fish" >>"$LOG_FILE" 2>&1 &
disown
printf 'Started Yahpax Quickshell; log: %s\n' "$LOG_FILE"
