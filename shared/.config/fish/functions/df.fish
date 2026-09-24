function df
    set -l repo "$HOME/github/dotfiles"
    set -l config "$HOME/.config/dotfiles/paths.conf"
    set -l target $argv[1]

    # ─────────────────────────────────────────────
    # Validate
    # ─────────────────────────────────────────────

    if test (count $argv) -ne 1
        echo "Usage: df <caelestia|yahpax>"
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
    # Repository must be clean
    # ─────────────────────────────────────────────

    if not git -C "$repo" diff --quiet; or not git -C "$repo" diff --cached --quiet

        echo "ERROR: repository has unrelated changes." >&2
        git -C "$repo" status --short
        return 1

    end

    # ─────────────────────────────────────────────
    # Update repository
    #
    # This does fetch remote changes, because df
    # needs the latest GitHub state.
    # ─────────────────────────────────────────────

    git -C "$repo" pull --ff-only
    or return 1

    # ─────────────────────────────────────────────
    # Build restore plan
    # ─────────────────────────────────────────────

    set -l files
    set -l dirs

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

        set -l local_path "$HOME/$path"
        set -l repo_path "$repo/$scope/$path"

        if test "$type" = dir

            set -a dirs "$scope|$path"

        else

            set -a files "$scope|$path"

        end

    end < "$config"

    # ─────────────────────────────────────────────
    # Show plan
    # ─────────────────────────────────────────────

    echo
    echo "Restore plan: $target (shared + $target)"
    echo

    echo "Directories:"
    for item in $dirs
        echo "  "(string split '|' -- "$item")[2]
    end

    echo
    echo "Files:"
    for item in $files
        echo "  "(string split '|' -- "$item")[2]
    end

    echo

    read -P "Back up and restore these paths? [y/N] " -l answer

    if not string match -q -r '^(y|yes)$' -- (string lower -- "$answer")

        echo "Cancelled; no local configuration was changed."
        return 1

    end

    # ─────────────────────────────────────────────
    # Backup
    # ─────────────────────────────────────────────

    set -l backup "$HOME/.config/dotfiles-backups/"(date '+%Y-%m-%d_%H-%M-%S')"-$target"

    mkdir -p "$backup"

    # ─────────────────────────────────────────────
    # Restore directories
    # ─────────────────────────────────────────────

    for item in $dirs

        set -l parts (string split '|' -- "$item")
        set -l scope "$parts[1]"
        set -l path "$parts[2]"

        set -l local_path "$HOME/$path"
        set -l repo_path "$repo/$scope/$path"

        if not test -d "$repo_path"
            echo "WARNING: repository directory missing:"
            echo "  $repo_path"
            continue
        end

        # Backup existing directory.
        if test -d "$local_path"

            set -l backup_path "$backup/$path"

            mkdir -p "$backup_path"

            cp -a "$local_path/." "$backup_path/"

        end

        # Restore entire directory.
        mkdir -p "$local_path"

        rsync -a --delete \
            "$repo_path/" \
            "$local_path/"

    end

    # ─────────────────────────────────────────────
    # Restore files
    # ─────────────────────────────────────────────

    for item in $files

        set -l parts (string split '|' -- "$item")
        set -l scope "$parts[1]"
        set -l path "$parts[2]"

        set -l local_path "$HOME/$path"
        set -l repo_path "$repo/$scope/$path"

        if not test -f "$repo_path"

            echo "WARNING: repository file missing:"
            echo "  $repo_path"

            continue

        end

        # Backup existing file.
        if test -e "$local_path"

            set -l backup_path "$backup/$path"

            mkdir -p (dirname "$backup_path")
            cp -p "$local_path" "$backup_path"

        end

        # Restore.
        mkdir -p (dirname "$local_path")
        cp -p "$repo_path" "$local_path"

    end

    echo
    echo "Dotfiles fetched successfully."
    echo "Backup: $backup"
end
