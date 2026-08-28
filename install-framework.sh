#!/bin/bash

UCTL_DIR="$HOME/.uctl"
BIN_DIR="$UCTL_DIR/bin"
MODULES_DIR="$UCTL_DIR/modules"
ROUTER_PATH="$BIN_DIR/uctl"
COMPLETION_PATH="$UCTL_DIR/autocomplete.bash"

echo "[*] Inicjalizacja frameworka uctl..."

mkdir -p "$BIN_DIR"
mkdir -p "$MODULES_DIR"

# 1. Tworzenie głównego routera
cat << 'EOF' > "$ROUTER_PATH"
#!/bin/bash

MODULES_DIR="$HOME/.uctl/modules"
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

show_help() {
    echo -e "${GREEN}Framework uctl (User Control)${NC}"
    echo -e "Użycie: uctl <moduł> [argumenty]\n"
    echo "Dostępne moduły:"
    
    if [ -d "$MODULES_DIR" ]; then
        for module in "$MODULES_DIR"/*.sh; do
            [ -e "$module" ] || continue
            basename "$module" .sh | sed 's/^/  - /'
        done
    else
        echo "  (brak zainstalowanych modułów)"
    fi
}

MODULE_NAME="$1"

if [ -z "$MODULE_NAME" ] || [ "$MODULE_NAME" == "-h" ] || [ "$MODULE_NAME" == "--help" ]; then
    show_help
    exit 0
fi

MODULE_PATH="$MODULES_DIR/${MODULE_NAME}.sh"

if [ ! -f "$MODULE_PATH" ]; then
    echo -e "${RED}Błąd: Nieznany moduł '${MODULE_NAME}'${NC}"
    echo "Stwórz go komendą: uctl edit ${MODULE_NAME}"
    exit 1
fi

bash "$MODULE_PATH" "${@:2}"
EOF

chmod +x "$ROUTER_PATH"

# 2. Tworzenie skryptu autouzupełniania (obsługa klawisza Tab)
cat << 'EOF' > "$COMPLETION_PATH"
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
EOF

# 3. Konfiguracja ~/.bashrc (PATH i Autouzupełnianie)
BASHRC="$HOME/.bashrc"

if ! grep -q 'export PATH="$HOME/.uctl/bin:$PATH"' "$BASHRC"; then
    echo -e '\n# Framework uctl' >> "$BASHRC"
    echo 'export PATH="$HOME/.uctl/bin:$PATH"' >> "$BASHRC"
    echo "[+] Dodano uctl do zmiennej PATH."
fi

if ! grep -q 'autocomplete.bash' "$BASHRC"; then
    echo 'if [ -f "$HOME/.uctl/autocomplete.bash" ]; then' >> "$BASHRC"
    echo '    source "$HOME/.uctl/autocomplete.bash"' >> "$BASHRC"
    echo 'fi' >> "$BASHRC"
    echo "[+] Podpięto autouzupełnianie (klawisz Tab)."
fi

echo "[+] Gotowe! Przeładuj terminal komendą: source ~/.bashrc"
