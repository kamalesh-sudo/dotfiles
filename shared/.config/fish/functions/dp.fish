function dp
    set -l repo "$HOME/github/dotfiles"
    set -l config "$HOME/.config/dotfiles/paths.conf"
    set -l target $argv[1]

    # ─────────────────────────────────────────────
    # Validate
    # ─────────────────────────────────────────────

    if test (count $argv) -lt 1
        echo "Usage: dp <caelestia|yahpax> [commit message]"
        return 1
    end

    if not string match -q -r '^(caelestia|yahpax)$' -- "$target"
        echo "ERROR: invalid target: $target" >&2
        return 1
    end

    if not test -d "$repo/.git"
        echo "ERROR: repository not found: $repo" >&2
        return 1
    end

    if not test -f "$config"
        echo "ERROR: path configuration not found: $config" >&2
        return 1
    end

    # ─────────────────────────────────────────────
    # Repository must start clean
    # ─────────────────────────────────────────────

    if not git -C "$repo" diff --quiet; or not git -C "$repo" diff --cached --quiet
        echo "ERROR: repository has unrelated changes." >&2
        git -C "$repo" status --short
        return 1
    end

    # ─────────────────────────────────────────────
    # Read path configuration
    # ─────────────────────────────────────────────

    set -l repo_paths

    while read -l line

        set line (string trim -- "$line")

        if test -z "$line"; or string match -q '#*' -- "$line"
            continue
        end

        set -l entry (string split '|' -- "$line")

        if test (count $entry) -ne 3
            echo "ERROR: invalid path entry:"
            echo "  $line"
            return 1
        end

        set -l scope "$entry[1]"
        set -l type "$entry[2]"
        set -l path "$entry[3]"

        if test "$scope" != shared; and test "$scope" != "$target"
            continue
        end

        if test "$type" != dir; and test "$type" != file
            echo "ERROR: type must be 'dir' or 'file': $line" >&2
            return 1
        end

        set -l source "$HOME/$path"
        set -l destination "$repo/$scope/$path"

        set -a repo_paths "$scope/$path"

        # ─────────────────────────────────────────
        # Directory
        # ─────────────────────────────────────────

        if test "$type" = dir

            if test -d "$source"

                mkdir -p "$destination"

                rsync -a --delete \
                    "$source/" \
                    "$destination/"

            else

                echo "WARNING: directory does not exist:"
                echo "  $source"

                if test -d "$destination"
                    rm -rf -- "$destination"
                end

            end

        # ─────────────────────────────────────────
        # File
        # ─────────────────────────────────────────

        else

            if test -f "$source"

                mkdir -p (dirname "$destination")
                cp -p "$source" "$destination"

            else

                echo "WARNING: file does not exist:"
                echo "  $source"

                if test -e "$destination"
                    rm -f -- "$destination"
                end

            end

        end

    end < "$config"

    # ─────────────────────────────────────────────
    # Stage ONLY configured paths
    # ─────────────────────────────────────────────

    for path in $repo_paths

        if test -e "$repo/$path"

            git -C "$repo" add -A -- "$path"
            or return 1

        else if git -C "$repo" ls-files --error-unmatch -- "$path" >/dev/null 2>&1

            git -C "$repo" add -u -- "$path"
            or return 1

        end

    end

    # ─────────────────────────────────────────────
    # Show changes
    # ─────────────────────────────────────────────

    echo
    echo "Changes for: $target (shared + $target)"
    echo

    git -C "$repo" diff --cached --name-status

    echo
    git -C "$repo" diff --cached --stat

    # ─────────────────────────────────────────────
    # Nothing changed
    # ─────────────────────────────────────────────

    if git -C "$repo" diff --cached --quiet

        echo
        echo "No changes to commit."
        return 0

    end

    # ─────────────────────────────────────────────
    # Commit message
    # ─────────────────────────────────────────────

    set -l details (string join ' ' $argv[2..-1])

    if test -z "$details"
        read -P "Commit message: " details
    end

    if test -z "$details"

        echo "ERROR: commit message is required."
        git -C "$repo" reset --quiet
        return 1

    end

    # ─────────────────────────────────────────────
    # Confirmation
    # ─────────────────────────────────────────────

    echo
    read -P "Commit and push these exact changes? [y/N] " -l answer

    if not string match -q -r '^(y|yes)$' -- (string lower -- "$answer")

        git -C "$repo" reset --quiet

        echo "Cancelled; changes were unstaged."
        return 1

    end

    # ─────────────────────────────────────────────
    # Commit
    # ─────────────────────────────────────────────

    git -C "$repo" commit -m "config($target): $details"
    or begin
        git -C "$repo" reset --quiet
        return 1
    end

    # ─────────────────────────────────────────────
    # Push
    #
    # Do NOT fetch old remote history.
    # ─────────────────────────────────────────────

    set -l branch (git -C "$repo" branch --show-current)

    set -l remote_sha (
        git -C "$repo" ls-remote origin "refs/heads/$branch" |
        string split \t |
        head -n 1
    )

    if test -n "$remote_sha"

        git -C "$repo" push \
            --force-with-lease="refs/heads/$branch:$remote_sha" \
            -u origin "$branch"

        or return 1

    else

        git -C "$repo" push -u origin "$branch"
        or return 1

    end

    echo
    echo "Push successful."
    echo "Target: $target"
    echo "Branch: $branch"
    echo "HEAD: "(git -C "$repo" rev-parse --short HEAD)
end
