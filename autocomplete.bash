_uctl_completions() {
    local cur prev module
    cur="${COMP_WORDS[COMP_CWORD]}"     # Aktualnie wpisywane słowo
    prev="${COMP_WORDS[COMP_CWORD-1]}"  # Poprzednie słowo

    # POZIOM 1: Autouzupełnianie nazw modułów (np. po wpisaniu 'uctl <TAB>')
    if [ "$COMP_CWORD" -eq 1 ]; then
        local modules=""
        for f in "$HOME/.uctl/modules/"*.sh; do
            [ -e "$f" ] || continue
            name=$(basename "$f" .sh)
            modules="$modules $name"
        done
        COMPREPLY=( $(compgen -W "${modules}" -- "${cur}") )
        return 0
    fi

    # POZIOM 2: Autouzupełnianie argumentów dla konkretnych modułów
    if [ "$COMP_CWORD" -eq 2 ]; then
        module="${COMP_WORDS[1]}"
        
        case "$module" in
            python)
                # Szukamy folderów w ~/.uctl/projects/python/
                local projects=""
                local proj_dir="$HOME/.uctl/projects/python"
                if [ -d "$proj_dir" ]; then
                    for d in "$proj_dir/"*/; do
                        [ -d "$d" ] || continue
                        proj_name=$(basename "$d")
                        projects="$projects $proj_name"
                    done
                fi
                COMPREPLY=( $(compgen -W "${projects}" -- "${cur}") )
                ;;
            # Tutaj w przyszłości można łatwo dodać autouzupełnianie dla modułu esp!
            esp)
                local projects=""
                local proj_dir="$HOME/.uctl/projects/esp"
                if [ -d "$proj_dir" ]; then
                    for d in "$proj_dir/"*/; do
                        [ -d "$d" ] || continue
                        proj_name=$(basename "$d")
                        projects="$projects $proj_name"
                    done
                fi
                COMPREPLY=( $(compgen -W "${projects}" -- "${cur}") )
                ;;
            *)
                COMPREPLY=()
                ;;
        esac
        return 0
    fi
}

complete -F _uctl_completions uctl
