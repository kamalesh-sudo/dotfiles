function lsc
    realpath $argv[1] | tee /dev/tty | wl-copy
end
