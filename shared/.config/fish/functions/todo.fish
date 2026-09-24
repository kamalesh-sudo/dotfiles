function todo --description 'Add a Quickshell sticky-note todo'
    set -l text ''
    set -l reminder ''
    set -l waiting_for_text 0
    set -l waiting_for_time 0

    for arg in $argv
        if test $waiting_for_text -eq 1
            set text $arg
            set waiting_for_text 0
        else if test $waiting_for_time -eq 1
            set reminder $arg
            set waiting_for_time 0
        else if test "$arg" = '-t'
            set waiting_for_time 1
        else if test -z "$text"
            set text $arg
        else
            echo "todo: unexpected argument: $arg" >&2
            return 2
        end
    end

    if test $waiting_for_time -eq 1
        echo 'todo: -t requires HH:MM' >&2
        return 2
    end
    if test -z "$text"
        echo 'usage: todo "text" [-t HH:MM]' >&2
        return 2
    end
    if test -n "$reminder"; and not string match -rq '^(?:[01][0-9]|2[0-3]):[0-5][0-9]$' -- "$reminder"
        echo 'todo: reminder must be HH:MM' >&2
        return 2
    end

    set -l helper "$HOME/.config/quickshell/scripts/todo-store.py"
    if not command -q python3
        echo 'todo: python3 is required' >&2
        return 1
    end
    python3 $helper add --text "$text" --time "$reminder"
    if test $status -ne 0
        return $status
    end
    if command -q qs
        qs ipc call todoBoard refresh >/dev/null 2>&1
    end
end
