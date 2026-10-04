function qb
    setsid qutebrowser \
                --basedir ~/.config/qutebrowser-burp \
                $argv >/dev/null 2>&1 &
end
