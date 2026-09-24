function sm
    set -l dir .
    set -l count 10
    
    if test (count $argv) -ge 1
        if string match -qr '^[0-9]+$' -- $argv[1]
            set count $argv[1]
        else
            set dir $argv[1]
        end
    end
    
    if test (count $argv) -ge 2
        set count $argv[2]
    end
    
    if not test -d "$dir"
        echo "sm: directory not found: $dir"
        return 1
    end
    
    find "$dir" -mindepth 1 -maxdepth 1 -exec du -sh {} + 2>/dev/null \
                | sort -hr | head -n $count
end
