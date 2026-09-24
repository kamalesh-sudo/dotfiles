function ext --description 'Extract archives with optional destination'

    if test (count $argv) -lt 1
        echo "Usage: extract <archive> [destination]"
        return 1
    end
    
    set -l file $argv[1]
    
    if not test -f "$file"
        echo "extract: archive not found: $file"
        return 1
    end
    
    set file (realpath "$file")
    
    # ─────────────────────────────────────────────
    # Destination
    # ─────────────────────────────────────────────
    
    if test (count $argv) -ge 2
        set dest (realpath -m "$argv[2]")
    else
        # Create destination beside archive
        set archive_dir (dirname "$file")
        set filename (basename "$file")
        
        # Remove archive extensions
        set name "$filename"
        
        switch "$name"
            case "*.tar.bz2"
                set name (string replace -r '\.tar\.bz2$' '' "$name")
            case "*.tar.gz"
                set name (string replace -r '\.tar\.gz$' '' "$name")
            case "*.tar.xz"
                set name (string replace -r '\.tar\.xz$' '' "$name")
            case "*.tar.zst"
                set name (string replace -r '\.tar\.zst$' '' "$name")
            case "*.tar.lz4"
                set name (string replace -r '\.tar\.lz4$' '' "$name")
            case "*.tbz2"
                set name (string replace -r '\.tbz2$' '' "$name")
            case "*.tbz"
                set name (string replace -r '\.tbz$' '' "$name")
            case "*.tgz"
                set name (string replace -r '\.tgz$' '' "$name")
            case "*.txz"
                set name (string replace -r '\.txz$' '' "$name")
            case "*.tzst"
                set name (string replace -r '\.tzst$' '' "$name")
            case "*.tar"
                set name (string replace -r '\.tar$' '' "$name")
            case "*.zip"
                set name (string replace -r '\.zip$' '' "$name")
            case "*.rar"
                set name (string replace -r '\.rar$' '' "$name")
            case "*.7z"
                set name (string replace -r '\.7z$' '' "$name")
            case "*.iso"
                set name (string replace -r '\.iso$' '' "$name")
            case "*.gz"
                set name (string replace -r '\.gz$' '' "$name")
            case "*.bz2"
                set name (string replace -r '\.bz2$' '' "$name")
            case "*.xz"
                set name (string replace -r '\.xz$' '' "$name")
            case "*.zst"
                set name (string replace -r '\.zst$' '' "$name")
            case "*.lzma"
                set name (string replace -r '\.lzma$' '' "$name")
            case '*'
                set name "$filename"
        end
        
        set dest "$archive_dir/$name"
    end
    
    # Create destination
    mkdir -p -- "$dest"
    
    if test $status -ne 0
        echo "extract: cannot create destination: $dest"
        return 1
    end
    
    # ─────────────────────────────────────────────
    # Extract
    # ─────────────────────────────────────────────
    
    switch "$file"
    
        case "*.tar.bz2" "*.tbz" "*.tbz2"
            tar -xjf "$file" -C "$dest"
            
        case "*.tar.gz" "*.tgz"
            tar -xzf "$file" -C "$dest"
            
        case "*.tar.xz" "*.txz"
            tar -xJf "$file" -C "$dest"
            
        case "*.tar.zst" "*.tzst"
            tar --use-compress-program=unzstd -xf "$file" -C "$dest"
            
        case "*.tar.lz4"
            tar --use-compress-program=lz4 -xf "$file" -C "$dest"
            
        case "*.tar"
            tar -xf "$file" -C "$dest"
            
        case "*.zip"
            unzip -q "$file" -d "$dest"
            
        case "*.rar"
            if not type -q unrar
                echo "extract: unrar is not installed"
                return 1
            end
            unrar x -o+ "$file" "$dest/"
            
        case "*.7z"
            7z x "$file" "-o$dest" -y
            
        case "*.iso"
            7z x "$file" "-o$dest" -y
            
        case "*.bz2"
            bunzip2 -c -- "$file" >"$dest/"(basename "$file" .bz2)
            
        case "*.gz"
            gunzip -c -- "$file" >"$dest/"(basename "$file" .gz)
            
        case "*.xz"
            xz -dc -- "$file" >"$dest/"(basename "$file" .xz)
            
        case "*.zst"
            unzstd -c -- "$file" >"$dest/"(basename "$file" .zst)
            
        case "*.lzma"
            unlzma -c -- "$file" >"$dest/"(basename "$file" .lzma)
            
        case '*'
            echo "extract: unsupported format: "(basename "$file")
            return 1
    end
    
    set -l result $status
    
    if test $result -eq 0
        echo
        echo "Extracted:"
        echo "  "(basename "$file")
        echo "→ $dest"
    else
        echo "extract: extraction failed"
        return $result
    end
end
