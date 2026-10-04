function dp
    set -l repo "$HOME/github/dotfiles"
    set -l config "$repo/paths.conf"
    set -l state "$repo/state.conf"
    
    # ------------------------------------------------------------
    # Validation
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
    
    # ------------------------------------------------------------
    # First run: create state
    # ------------------------------------------------------------
    
    if not test -s "$state"
        cp "$config" "$state"
        
        if test $status -ne 0
            echo "ERROR: failed to create state.conf"
            return 1
        end
        
        echo "Created state.conf from paths.conf"
    end
    
    # ------------------------------------------------------------
    # Remove paths that disappeared from paths.conf
    # ------------------------------------------------------------
    
    while read -l old_path
        set old_path (string trim -- "$old_path")
        
        test -z "$old_path"; and continue
        string match -q '#*' -- "$old_path"; and continue
        
        if not grep -Fxq -- "$old_path" "$config"
            set -l destination "$repo/$old_path"
            
            if test -e "$destination"; or test -L "$destination"
                echo "REMOVE: $destination"
                
                rm -rf -- "$destination"
                
                if test $status -ne 0
                    echo "ERROR: failed to remove: $destination"
                    return 1
                end
                
                # Remove empty parent directories.
                set -l parent (dirname "$destination")
                
                while test "$parent" != "$repo"
                    if test -d "$parent"
                        set -l entries (command ls -A -- "$parent" 2>/dev/null)
                        
                        if test (count $entries) -eq 0
                            rmdir -- "$parent"
                            
                            if test $status -ne 0
                                break
                            end
                            
                            set parent (dirname "$parent")
                        else
                            break
                        end
                    else
                        break
                    end
                end
            end
        end
    end < "$state"
    
    # ------------------------------------------------------------
    # Sync paths from paths.conf
    # ------------------------------------------------------------
    
    while read -l path
        set path (string trim -- "$path")
        
        test -z "$path"; and continue
        string match -q '#*' -- "$path"; and continue
        
        set -l source "$HOME/$path"
        set -l destination "$repo/$path"
        
        if not test -e "$source"; and not test -L "$source"
            echo "ERROR: source does not exist: $source"
            return 1
        end
        
        mkdir -p -- (dirname "$destination")
        
        if test -d "$source"
            rsync -a --delete -- "$source/" "$destination/"
        else
            cp -f -- "$source" "$destination"
        end
        
        if test $status -ne 0
            echo "ERROR: failed to sync: $path"
            return 1
        end
        
        echo "SYNC: $source → $destination"
    end < "$config"
    
    # ------------------------------------------------------------
    # Stage everything
    # ------------------------------------------------------------
    
    git -C "$repo" add -A
    
    if test $status -ne 0
        echo "ERROR: git add failed."
        return 1
    end
    
    # ------------------------------------------------------------
    # Check for changes
    # ------------------------------------------------------------
    
    if git -C "$repo" diff --cached --quiet
        echo
        echo "No Git changes."
        return 0
    end
    
    # ------------------------------------------------------------
    # Show changes
    # ------------------------------------------------------------
    
    echo
    echo "Git changes:"
    echo "----------------------------------------"
    git -C "$repo" status --short
    echo "----------------------------------------"
    
    echo
    git -C "$repo" diff --cached --stat
    
    # ------------------------------------------------------------
    # Get previous commit message
    # ------------------------------------------------------------
    
    set -l previous_message (
        git -C "$repo" log -1 --pretty=%B 2>/dev/null |
            string collect |
            string trim
    )
    
    # ------------------------------------------------------------
    # Commit message
    # ------------------------------------------------------------
    
    while true
        echo
        if test -n "$previous_message"
            echo "Commit message:"
            echo "  Enter message"
            echo "  q = reuse previous message"
            echo "  Esc = cancel"
        else
            echo "Commit message:"
            echo "  Enter message"
            echo "  Esc = cancel"
        end
        
        read -P "> " message
        
        set -l read_status $status
        
        # Ctrl-C / Ctrl-D / read failure
        if test $read_status -ne 0
            echo
            echo "Cancelled."
            return 130
        end
        
        # Fish read normally does not provide a portable Esc-specific
        # status, so a literal q is the explicit shortcut.
        if test "$message" = q; or test "$message" = Q
            if test -n "$previous_message"
                set message "$previous_message"
                break
            else
                echo "No previous commit message available."
                continue
            end
        end
        
        # Empty message
        if test -z (string trim -- "$message")
            echo "Commit message cannot be empty."
            continue
        end
        
        break
    end
    
    # ------------------------------------------------------------
    # Commit
    # ------------------------------------------------------------
    
    echo
    echo "Commit:"
    echo "  $message"
    
    git -C "$repo" commit -m "$message"
    
    if test $status -ne 0
        echo
        echo "ERROR: commit failed."
        return 1
    end
    
    # ------------------------------------------------------------
    # Update state only after successful commit
    # ------------------------------------------------------------
    
    cp "$config" "$state"
    
    if test $status -ne 0
        echo
        echo "WARNING: commit succeeded but state.conf could not be updated."
        echo "Do NOT run dp again until state.conf is repaired."
        return 1
    end
    
    # ------------------------------------------------------------
    # Push confirmation
    # ------------------------------------------------------------
    
    while true
        echo
        read -P "Push to GitHub? [Y/n] " push_answer
        
        set -l read_status $status
        
        # Ctrl-C / Ctrl-D
        if test $read_status -ne 0
            echo
            echo "Push cancelled. Commit remains local."
            return 0
        end
        
        set push_answer (string lower -- (string trim -- "$push_answer"))
        
        # Empty = Yes
        if test -z "$push_answer"; or test "$push_answer" = y; or test "$push_answer" = yes
            break
        end
        
        # No
        if test "$push_answer" = n; or test "$push_answer" = no
            echo
            echo "Push skipped. Commit remains local."
            return 0
        end
        
        # q = cancel push
        if test "$push_answer" = q
            echo
            echo "Push cancelled. Commit remains local."
            return 0
        end
        
        echo "Please enter Y, n, or q."
    end
    
    # ------------------------------------------------------------
    # Push
    # ------------------------------------------------------------
    
    echo
    echo "Pushing to GitHub..."
    
    git -C "$repo" push
    
    if test $status -ne 0
        echo
        echo "ERROR: push failed."
        echo "Commit remains local."
        return 1
    end
    
    echo
    echo "Successfully committed and pushed."
end
