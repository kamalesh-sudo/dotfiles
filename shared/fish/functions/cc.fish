function cc
    set -l failed 0
    
    function _clean
        set -l target $argv[1]
        if test -e "$target"
            rm -rf "$target" 2>/dev/null
            if test $status -ne 0
                echo "  [FAIL] $target"
                set failed 1
            else
                echo "  [OK]   $target"
            end
        end
    end
    
    function _sudo_clean
        set -l target $argv[1]
        if test -e "$target"
            sudo rm -rf "$target" 2>/dev/null
            if test $status -ne 0
                echo "  [FAIL] $target"
                set failed 1
            else
                echo "  [OK]   $target"
            end
        end
    end
    
    echo "========================================"
    echo "        AGGRESSIVE CACHE CLEANUP"
    echo "========================================"
    
    # --------------------------------------------------
    # USER CACHE
    # --------------------------------------------------
    
    echo
    echo "[1/10] User caches"
    
    _clean ~/.cache
    mkdir -p ~/.cache
    
    _clean ~/.thumbnails
    _clean ~/.local/share/Trash
    
    # --------------------------------------------------
    # COMMON APPLICATION CACHES
    # --------------------------------------------------
    
    echo
    echo "[2/10] Application caches"
    
    _clean ~/.cache/thumbnails
    _clean ~/.cache/fontconfig
    _clean ~/.cache/mesa
    _clean ~/.cache/mesa_shader_cache
    _clean ~/.cache/mesa_shader_cache_db
    _clean ~/.cache/qtshadercache
    _clean ~/.cache/qtwebengine
    _clean ~/.cache/qutebrowser
    _clean ~/.cache/chromium
    _clean ~/.cache/google-chrome
    _clean ~/.cache/spotify
    _clean ~/.cache/lazygit
    _clean ~/.cache/starship
    _clean ~/.cache/nvim
    
    # --------------------------------------------------
    # DEVELOPMENT CACHES
    # --------------------------------------------------
    
    echo
    echo "[3/10] Development caches"
    
    _clean ~/.cache/pip
    _clean ~/.cache/uv
    _clean ~/.cache/pypoetry
    _clean ~/.cache/yarn
    _clean ~/.cache/pnpm
    _clean ~/.npm/_cacache
    
    # Rust cache
    _clean ~/.cargo/registry/cache
    _clean ~/.cargo/git/db
    
    # Go
    if command -q go
        echo "  Cleaning Go build/test cache..."
        go clean -cache -testcache 2>/dev/null
        or echo "  [WARN] Go cache cleanup failed"
    end
    
    # ccache
    if command -q ccache
        echo "  Cleaning ccache..."
        ccache -C 2>/dev/null
        or echo "  [WARN] ccache cleanup failed"
    end
    
    # --------------------------------------------------
    # FLATPAK
    # --------------------------------------------------
    
    echo
    echo "[4/10] Flatpak caches"
    
    if command -q flatpak
        flatpak uninstall --unused --delete-data -y 2>/dev/null
        or echo "  [WARN] Flatpak unused cleanup failed"
        
        for dir in ~/.var/app/*/cache
            if test -d "$dir"
                rm -rf "$dir"/* 2>/dev/null
            end
        end
    end
    
    # --------------------------------------------------
    # PACKAGE CACHE
    # --------------------------------------------------
    
    echo
    echo "[5/10] Pacman cache"
    
    if command -q paccache
        sudo paccache -r -k 0 2>/dev/null
        or echo "  [WARN] paccache failed"
    else
        echo "  paccache not installed; using pacman"
        sudo pacman -Scc --noconfirm 2>/dev/null
        or echo "  [WARN] pacman cache cleanup failed"
    end
    
    # --------------------------------------------------
    # SYSTEM TEMPORARY FILES
    # --------------------------------------------------
    
    echo
    echo "[6/10] System temporary files"
    
    # Only contents are removed; directories themselves remain.
    sudo find /tmp -mindepth 1 -maxdepth 1 -exec rm -rf {} + 2>/dev/null
    or echo "  [WARN] Some /tmp files could not be removed"
    
    sudo find /var/tmp -mindepth 1 -maxdepth 1 -exec rm -rf {} + 2>/dev/null
    or echo "  [WARN] Some /var/tmp files could not be removed"
    
    # --------------------------------------------------
    # SYSTEMD JOURNAL
    # --------------------------------------------------
    
    echo
    echo "[7/10] System logs"
    
    sudo journalctl --vacuum-time=3d 2>/dev/null
    or echo "  [WARN] Journal cleanup failed"
    
    # --------------------------------------------------
    # COREDUMPS
    # --------------------------------------------------
    
    echo
    echo "[8/10] Core dumps"
    
    if command -q coredumpctl
        sudo coredumpctl --vacuum-time=3d 2>/dev/null
        or echo "  [WARN] Core dump cleanup failed"
    end
    
    # --------------------------------------------------
    # PACMAN DATABASE LOCK
    # --------------------------------------------------
    
    echo
    echo "[9/10] Pacman lock"
    
    set -l package_running 0
    
    for proc in pacman yay paru
        if pgrep -x $proc >/dev/null 2>&1
            set package_running 1
            echo "  [SKIP] $proc is running"
        end
    end
    
    if test $package_running -eq 0
        if test -f /var/lib/pacman/db.lck
            sudo rm -f /var/lib/pacman/db.lck 2>/dev/null
            if test $status -eq 0
                echo "  [OK]   Removed stale pacman lock"
            else
                echo "  [FAIL] Could not remove pacman lock"
                set failed 1
            end
        else
            echo "  [OK]   No pacman lock"
        end
    else
        echo "  [SKIP] Pacman lock preserved"
    end
    
    # --------------------------------------------------
    # FINAL CLEANUP
    # --------------------------------------------------
    
    echo
    echo "[10/10] Final cleanup"
    
    sync
    
    echo
    echo "========================================"
    
    if test $failed -eq 0
        echo "Cleanup completed successfully."
    else
        echo "Cleanup completed with some failures."
        echo "Check the [FAIL] entries above."
    end
    
    echo "========================================"
end
