function fish_greeting
    figlet -f ~/.local/share/fonts/figlet/Graffiti.flf sparks
    set_color normal
    command -v fastfetch &>/dev/null && fastfetch --key-padding-left 5
end
