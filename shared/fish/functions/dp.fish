function dp
    set -l repo "$HOME/github/dotfiles"
    set -l config "$HOME/.config/dotfiles/paths.conf"
    set -l state "$HOME/.config/dotfiles/state.conf"
    set -l branch master

    if test (count $argv) -lt 1
        echo "Usage: dp <yahpax|caelestia> [commit message]"
        return 1
    end

    set -l target $argv[1]

    if not contains -- $target yahpax caelestia
        echo "ERROR: target must be yahpax or caelestia"
        return 1
    end

    set -l message "$argv[2..-1]" | string join " "

    if test -z "$message"
        read -P "Commit message: " message
        test -n "$message"; or return 1
    end

    # ------------------------------------------------------------
    # Validate
    # ------------------------------------------------------------

    if not test -d "$repo/.git"
        echo "ERROR: Git repository not found: $repo"
        return 1
    end

    if not test -f "$config"
        echo "ERROR: paths.conf not found: $config"
        return 1
    end

    if not command -q rsync
        echo "ERROR: rsync is required."
        return 1
    end

    if not git -C "$repo" diff --quiet
        echo "ERROR: repository has unstaged changes."
        git -C "$repo" status --short
        return 1
    end

    if not git -C "$repo" diff --cached --quiet
        echo "ERROR: repository has staged changes."
        git -C "$repo" status --short
        return 1
    end

    # ------------------------------------------------------------
    # Temporary files
    # ------------------------------------------------------------

    set -l tmpdir (mktemp -d)
    or return 1

    set -l current "$tmpdir/current"
    set -l new_scope "$tmpdir/new_scope"
    set -l old_scope "$tmpdir/old_scope"
    set -l removed "$tmpdir/removed"
    set -l new_paths "$tmpdir/new_paths"

    touch "$current" "$new_scope" "$old_scope" "$removed" "$new_paths"

    # ------------------------------------------------------------
    # Parse paths.conf
    # ------------------------------------------------------------

    while read -l line
        set line (string trim -- "$line")

        test -z "$line"; and continue
        string match -q '#*' -- "$line"; and continue

        set -l f (string split '|' -- "$line")

        if test (count $f) -ne 3
            echo "ERROR: invalid paths.conf line:"
            echo "$line"
            rm -rf "$tmpdir"
            return 1
        end

        set -l t (string trim -- "$f[1]")
        set -l type (string trim -- "$f[2]")
        set -l path (string trim -- "$f[3]")

        if not contains -- $t shared yahpax caelestia
            echo "ERROR: invalid target: $t"
            rm -rf "$tmpdir"
            return 1
        end

        if not contains -- $type dir file
            echo "ERROR: invalid type: $type"
            rm -rf "$tmpdir"
            return 1
        end

        if not string match -q '.config/*' -- "$path"
            echo "ERROR: path must start with .config/: $path"
            rm -rf "$tmpdir"
            return 1
        end

        set -l repo_path (string replace -r '^\.config/' '' -- "$path")

        printf '%s|%s|%s|%s\n' \
            "$t" "$type" "$path" "$repo_path" >> "$current"

    end < "$config"

    # ------------------------------------------------------------
    # Duplicate detection
    # ------------------------------------------------------------

    set -l duplicate (sort "$current" | uniq -d)

    if test -n "$duplicate"
        echo "ERROR: duplicate paths:"
        echo "$duplicate"
        rm -rf "$tmpdir"
        return 1
    end

    # ------------------------------------------------------------
    # Check overlapping paths
    # ------------------------------------------------------------

    set -l current_lines (cat "$current")

    for a_line in $current_lines
        set -l a (string split '|' -- "$a_line")

        for b_line in $current_lines
            set -l b (string split '|' -- "$b_line")

            test "$a_line" = "$b_line"; and continue
            test "$a[1]" = "$b[1]"; or continue

            if string match -q "$a[4]/*" -- "$b[4]"
                echo "ERROR: overlapping paths:"
                echo "  $a[1]/$a[4]"
                echo "  $b[1]/$b[4]"
                rm -rf "$tmpdir"
                return 1
            end
        end
    end

    # ------------------------------------------------------------
    # Load previous state
    # ------------------------------------------------------------

    if not test -f "$state"
        touch "$state"
    end

    while read -l line
        test -z "$line"; and continue
        string match -q '#*' -- "$line"; and continue

        set -l f (string split '|' -- "$line")

        test (count $f) -eq 4; or continue

        if test "$f[1]" = shared; or test "$f[1]" = "$target"
            echo "$line" >> "$old_scope"
        end
    end < "$state"

    # Current scope
    while read -l line
        set -l f (string split '|' -- "$line")

        if test "$f[1]" = shared; or test "$f[1]" = "$target"
            echo "$line" >> "$new_scope"
        end
    end < "$current"

    # ------------------------------------------------------------
    # Detect removed paths
    # ------------------------------------------------------------

    while read -l old_line
        test -z "$old_line"; and continue

        if not grep -Fqx -- "$old_line" "$new_scope"
            echo "$old_line" >> "$removed"
        end
    end < "$old_scope"

    # ------------------------------------------------------------
    # Show removed paths
    # ------------------------------------------------------------

    if test -s "$removed"
        echo
        echo "Removed paths:"

        while read -l line
            set -l f (string split '|' -- "$line")
            echo "  DELETE $f[1]/$f[4]"
        end < "$removed"
    end

    # ------------------------------------------------------------
    # Delete paths removed from paths.conf
    # ------------------------------------------------------------

    while read -l line
        test -z "$line"; and continue

        set -l f (string split '|' -- "$line")

        set -l old_target $f[1]
        set -l old_repo_path $f[4]

        set -l destination "$repo/$old_target/$old_repo_path"

        if test -e "$destination"; or test -L "$destination"
            echo "Deleting $destination"
            rm -rf "$destination"
        end
    end < "$removed"

    # ------------------------------------------------------------
    # Synchronize current paths
    # ------------------------------------------------------------

    echo
    echo "Synchronizing: $target"
    echo

    while read -l line
        test -z "$line"; and continue

        set -l f (string split '|' -- "$line")

        set -l entry_target $f[1]
        set -l entry_type $f[2]
        set -l source_path $f[3]
        set -l repo_path $f[4]

        set -l source "$HOME/$source_path"
        set -l destination "$repo/$entry_target/$repo_path"

        echo "  $entry_target/$repo_path"

        if test "$entry_type" = dir
            if not test -d "$source"
                echo "ERROR: directory does not exist:"
                echo "  $source"
                rm -rf "$tmpdir"
                return 1
            end

            mkdir -p "$destination"

            rsync -a --delete \
                "$source/" \
                "$destination/"

            if test $status -ne 0
                echo "ERROR: rsync failed."
                rm -rf "$tmpdir"
                return 1
            end

        else
            if not test -f "$source"
                echo "ERROR: file does not exist:"
                echo "  $source"
                rm -rf "$tmpdir"
                return 1
            end

            mkdir -p (dirname "$destination")
            cp -f "$source" "$destination"

            if test $status -ne 0
                echo "ERROR: copy failed."
                rm -rf "$tmpdir"
                return 1
            end
        end

    end < "$new_scope"

    # ------------------------------------------------------------
    # Remove unmanaged top-level repository entries
    #
    # IMPORTANT:
    # We read NEW_SCOPE with:
    #
    #   while read ... < "$new_scope"
    #
    # NOT:
    #
    #   for line in $new_scope
    #
    # ------------------------------------------------------------

    for repository_target in shared $target

        set -l target_dir "$repo/$repository_target"

        test -d "$target_dir"; or continue

        for item in "$target_dir"/*
            test -e "$item"; or test -L "$item"; or continue

            set -l name (basename "$item")
            set -l managed 0

            while read -l line
                set -l f (string split '|' -- "$line")

                test "$f[1]" = "$repository_target"; or continue

                set -l repo_path $f[4]
                set -l first_component (string split '/' -- "$repo_path")[1]

                if test "$first_component" = "$name"
                    set managed 1
                    break
                end

            end < "$new_scope"

            if test $managed -eq 0
                echo
                echo "Removing unmanaged:"
                echo "  $item"

                rm -rf "$item"
            end
        end
    end

    # ------------------------------------------------------------
    # Stage everything
    # ------------------------------------------------------------

    git -C "$repo" add -A

    if test $status -ne 0
        echo "ERROR: git add failed."
        rm -rf "$tmpdir"
        return 1
    end

    echo
    echo "Git changes:"
    git -C "$repo" status --short

    # ------------------------------------------------------------
    # Nothing changed
    # ------------------------------------------------------------

    if git -C "$repo" diff --cached --quiet
        echo
        echo "No changes to commit."
        rm -rf "$tmpdir"
        return 0
    end

    # ------------------------------------------------------------
    # Commit
    # ------------------------------------------------------------

    echo
    echo "Commit:"
    git -C "$repo" diff --cached --stat

    git -C "$repo" commit -m "config($target): $message"

    if test $status -ne 0
        echo "ERROR: commit failed."
        rm -rf "$tmpdir"
        return 1
    end

    # ------------------------------------------------------------
    # Push
    # ------------------------------------------------------------

    echo
    echo "Pushing to GitHub..."

    set -l remote_sha (
        git -C "$repo" ls-remote origin "refs/heads/$branch" |
        string split \t |
        head -n 1
    )

    if test -n "$remote_sha"
        git -C "$repo" push \
            --force-with-lease="refs/heads/$branch:$remote_sha" \
            -u origin "$branch"
    else
        git -C "$repo" push \
            -u origin "$branch"
    end

    if test $status -ne 0
        echo
        echo "ERROR: push failed."
        echo "state.conf was NOT updated."
        rm -rf "$tmpdir"
        return 1
    end

    # ------------------------------------------------------------
    # Update state only after successful push
    # ------------------------------------------------------------

    set -l new_state "$tmpdir/new_state"
    touch "$new_state"

    # Preserve other target's state.
    while read -l line
        test -z "$line"; and continue

        set -l f (string split '|' -- "$line")

        test (count $f) -eq 4; or continue

        if test "$f[1]" != shared; and test "$f[1]" != "$target"
            echo "$line" >> "$new_state"
        end
    end < "$state"

    # Add current state.
    cat "$new_scope" >> "$new_state"

    mv "$new_state" "$state"

    if test $status -ne 0
        echo
        echo "WARNING: push succeeded but state.conf update failed."
        rm -rf "$tmpdir"
        return 1
    end

    rm -rf "$tmpdir"

    echo
    echo "Successfully committed and pushed."
    echo "Target: $target"
end
