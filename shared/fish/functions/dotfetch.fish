function dotfetch
    set -l repo "$HOME/github/dotfiles"
    set -l target $argv[1]

    if test (count $argv) -ne 1; or not string match -q -r '^(caelestia|yahpax)$' -- "$target"
        echo "Usage: dotfetch <caelestia|yahpax>"
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

    git -C "$repo" pull --ff-only
    or return 1

    set -l manifests "$repo/shared/manifest" "$repo/$target/manifest"
    set -l create replace absent
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
            set -l local_path "$HOME/$entry[2]"
            set -l repo_path "$repo/$entry[3]"
            if test -f "$repo_path"
                if test -f "$local_path"
                    if not cmp -s "$repo_path" "$local_path"
                        set -a replace "$entry[2]"
                    end
                else
                    set -a create "$entry[2]"
                end
            else
                set -a absent "$entry[2]"
            end
        end < "$manifest"
    end

    echo "Restore plan: $target (shared + $target)"
    echo "Files to create: "(count $create)
    printf '%s\n' $create
    echo "Files to replace: "(count $replace)
    printf '%s\n' $replace
    echo "Files not recreated because repository entries are absent: "(count $absent)
    printf '%s\n' $absent
    if test (count $create) -eq 0; and test (count $replace) -eq 0
        echo "No local files will be changed."
        return 0
    end

    read -P "Back up and apply this exact plan? [y/N] " -l answer
    if not string match -q -r '^(y|yes)$' -- (string lower -- "$answer")
        echo "Cancelled; no working configuration was changed."
        return 1
    end

    set -l backup "$HOME/.config/dotfiles-backups/"(date '+%Y-%m-%d_%H-%M-%S')"-$target"
    mkdir -p "$backup"
    for manifest in $manifests
        while read -l line
            if test -z "$line"; or string match -q '#*' -- "$line"
                continue
            end
            set -l entry (string split '|' -- "$line")
            set -l local_path "$HOME/$entry[2]"
            set -l repo_path "$repo/$entry[3]"
            if test -f "$repo_path"
                if test -e "$local_path"
                    set -l backup_path "$backup/$entry[2]"
                    mkdir -p (dirname "$backup_path")
                    cp -p "$local_path" "$backup_path"
                end
                mkdir -p (dirname "$local_path")
                cp -p "$repo_path" "$local_path"
            end
        end < "$manifest"
    end
    echo "Dotfiles fetched successfully. Backup: $backup"
end
