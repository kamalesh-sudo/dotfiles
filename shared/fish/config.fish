if status is-interactive
    set -l is_hyprland 0
    if set -q HYPRLAND_INSTANCE_SIGNATURE
        set is_hyprland 1
    else if set -q XDG_CURRENT_DESKTOP; and string match -q '*Hyprland*' "$XDG_CURRENT_DESKTOP"
        set is_hyprland 1
    end

    if test $is_hyprland -eq 1
        set -gx STARSHIP_CONFIG "$HOME/.config/starship-yahpax.toml"
    else
        set -gx STARSHIP_CONFIG "$HOME/.config/starship.toml"
    end

    # Starship custom prompt
    command -v starship &> /dev/null && starship init fish | source

    # Direnv + Zoxide
    command -v direnv &> /dev/null && direnv hook fish | source
    command -v zoxide &> /dev/null && zoxide init fish --cmd cd | source

    # Better ls
    command -v eza &> /dev/null && alias ls='eza --icons --group-directories-first -1'

    # Abbrs
    abbr lg 'lazygit'
    abbr gd 'git diff'
    abbr ga 'git add .'
    abbr gc 'git commit -am'
    abbr gl 'git log'
    abbr gs 'git status'
    abbr gst 'git stash'
    abbr gsp 'git stash pop'
    abbr gp 'git push'
    abbr gpl 'git pull'
    abbr gsw 'git switch'
    abbr gsm 'git switch main'
    abbr gb 'git branch'
    abbr gbd 'git branch -d'
    abbr gco 'git checkout'
    abbr gsh 'git show'

    abbr l 'lsd'
    abbr ll 'lsd -l'
    abbr la 'lsd -a'
    abbr lla 'lsd -la'
    abbr lsf 'lsd ~/.config/fish/functions/'
    abbr c 'clear'

    # Caelestia's terminal palette is KDE-session-only.
    if test $is_hyprland -eq 0
        cat ~/.local/state/caelestia/sequences.txt 2> /dev/null
    end

    # For jumping between prompts in foot terminal
    function mark_prompt_start --on-event fish_prompt
        echo -en "\e]133;A\e\\"
    end

    # Caelestia's Fish additions are KDE-session-only.
    if test $is_hyprland -eq 0
        set -q XDG_CONFIG_HOME && set -l cConf $XDG_CONFIG_HOME/caelestia || set -l cConf $HOME/.config/caelestia
        source $cConf/user-config.fish 2> /dev/null
    end
end
