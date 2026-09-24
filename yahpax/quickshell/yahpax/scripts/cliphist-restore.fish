#!/usr/bin/env fish
# cliphist-restore.fish <full cliphist-list line>
#
# Content comes in via argv, not string interpolation — avoids any
# shell injection risk even if the copied content has quotes, $,
# backticks, etc.

if test (count $argv) -lt 1; or test -z "$argv[1]"
    echo "Usage: cliphist-restore.fish <line>" >&2
    exit 1
end

set -l LINE $argv[1]

printf '%s' "$LINE" | cliphist decode | wl-copy
