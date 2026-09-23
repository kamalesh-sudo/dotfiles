function dotpush
    set -l repo "$HOME/github/dotfiles"
    set -l target $argv[1]

    if test (count $argv) -lt 1; or not string match -q -r '^(caelestia|yahpax)$' -- "$target"
        echo "Usage: dotpush <caelestia|yahpax> [commit message]"
        return 1
    end
    if not test -d "$repo/.git"
        echo "ERROR: repository not found: $repo" >&2
        return 1
    end
    set -l repo_status (git -C "$repo" status --porcelain)
    if test (count $repo_status) -gt 0
        echo "ERROR: repository has unrelated working-tree or staged changes." >&2
        return 1
    end

    set -l manifests "$repo/shared/manifest" "$repo/$target/manifest"
    set -l stage_paths shared/manifest "$target/manifest"
    set -l destinations
    for manifest in $manifests
        if not test -f "$manifest"
            echo "ERROR: missing manifest: $manifest" >&2
            return 1
        end
        while read -l line
            if test -z "$line"; or string match -q '#*' -- "$line"
                continue
            end
            set -l entry (string split '|' -- "$line")
            if test (count $entry) -ne 3; or test "$entry[1]" != file
                echo "ERROR: manifest must contain file entries only: $manifest: $line" >&2
                return 1
            end
            set -l source "$HOME/$entry[2]"
            set -l destination "$repo/$entry[3]"
            if contains -- "$entry[3]" $destinations
                echo "ERROR: duplicate repository path in manifests: $entry[3]" >&2
                return 1
            end
            set -a destinations $entry[3]
            set -a stage_paths $entry[3]

            if test -f "$source"
                mkdir -p (dirname "$destination")
                cp -p "$source" "$destination"
            else
                # LOCAL -> REPOSITORY mirror semantics: missing local files
                # remove their manifest destination instead of restoring it.
                rm -f -- "$destination"
            end
        end < "$manifest"
    end

    set -l existing_stage
    for path in $stage_paths
        if test -e "$repo/$path"
            set -a existing_stage "$path"
        end
    end
    if test (count $existing_stage) -gt 0
        git -C "$repo" add -- $existing_stage
        or return 1
    end
    for path in $stage_paths
        if not test -e "$repo/$path"
            git -C "$repo" add -u -- "$path"
        end
    end

    echo "Changes for: $target (shared + $target)"
    git -C "$repo" diff --cached --name-status
    echo
    git -C "$repo" diff --cached --stat
    echo "Tracked files: "(git -C "$repo" ls-files | count)
    echo "Repository size: "(du -sh "$repo" | string split '\t' | head -n 1)
    if git -C "$repo" diff --cached --quiet
        echo "No changes to commit."
        return 0
    end

    set -l details (string join ' ' $argv[2..-1])
    if test -z "$details"
        read -P "Commit message: " details
    end
    if test -z "$details"
        echo "ERROR: commit message is required." >&2
        return 1
    end
    read -P "Commit and push these exact changes? [y/N] " -l answer
    if not string match -q -r '^(y|yes)$' -- (string lower -- "$answer")
        echo "Cancelled; staged changes were left in the repository."
        return 1
    end

    git -C "$repo" commit -m "config($target): $details"
    or return 1
    set -l branch (git -C "$repo" branch --show-current)
    git -C "$repo" fetch origin "$branch"
    or return 1
    git -C "$repo" push --force-with-lease -u origin "$branch"
end
