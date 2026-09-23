function fish_greeting
    #echo -ne '\x1b[38;5;16m'  # Set colour to primary
    figlet -f ~/.local/share/fonts/figlet/Graffiti.flf sparks
    set_color normal
    if not command -v fastfetch &>/dev/null
        return
    end

    set -l is_hyprland 0
    if set -q HYPRLAND_INSTANCE_SIGNATURE
        set is_hyprland 1
    else if set -q XDG_CURRENT_DESKTOP; and string match -q '*Hyprland*' "$XDG_CURRENT_DESKTOP"
        set is_hyprland 1
    end

    if test $is_hyprland -eq 1
        fastfetch --config "$HOME/.config/fastfetch/yahpax/config.jsonc" --key-padding-left 5
    else
        fastfetch --config "$HOME/.config/fastfetch/config.jsonc" --key-padding-left 5
    end
end
