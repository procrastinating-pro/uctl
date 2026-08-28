_uctl_completions() {
    local cur modules=""
    cur="${COMP_WORDS[COMP_CWORD]}"
    
    for f in "$HOME/.uctl/modules/"*.sh; do
        [ -e "$f" ] || continue
        name=$(basename "$f" .sh)
        modules="$modules $name"
    done

    COMPREPLY=( $(compgen -W "${modules}" -- "${cur}") )
    return 0
}

complete -F _uctl_completions uctl
