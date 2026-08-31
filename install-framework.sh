#!/bin/bash

UCTL_DIR="$HOME/.uctl"
BIN_DIR="$UCTL_DIR/bin"
MODULES_DIR="$UCTL_DIR/modules"
ROUTER_PATH="$BIN_DIR/uctl"
COMPLETION_PATH="$UCTL_DIR/autocomplete.bash"
CONFIG_FILE="$UCTL_DIR/config"

echo "[*] Inicjalizacja frameworka uctl..."

mkdir -p "$BIN_DIR"
mkdir -p "$MODULES_DIR"

# 1. Tworzenie domyślnego pliku konfiguracyjnego (jeśli nie istnieje)
if [ ! -f "$CONFIG_FILE" ]; then
    echo "[*] Tworzenie pliku konfiguracyjnego: $CONFIG_FILE"
    cat << 'EOF' > "$CONFIG_FILE"
# Główny plik konfiguracyjny frameworka uctl
UCTL_PROJECTS_DIR="$HOME/.uctl/projects"
UCTL_DEFAULT_EDITOR="vim"
UCTL_ENABLE_COLORS="true"
EOF
fi

# 2. Tworzenie głównego routera
echo "[*] Generowanie routera (bin/uctl)..."
cat << 'EOF' > "$ROUTER_PATH"
#!/bin/bash

UCTL_DIR="$HOME/.uctl"
MODULES_DIR="$UCTL_DIR/modules"
CONFIG_FILE="$UCTL_DIR/config"

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Wczytanie konfiguracji
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    UCTL_PROJECTS_DIR="$UCTL_DIR/projects"
    UCTL_DEFAULT_EDITOR="vim"
fi

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

# 3. Tworzenie ZAAWANSOWANEGO skryptu autouzupełniania (TERAZ DYNAMICZNEGO)
echo "[*] Konfiguracja dynamicznego autouzupełniania..."
cat << 'EOF' > "$COMPLETION_PATH"
_uctl_completions() {
    local cur prev module
    cur="${COMP_WORDS[COMP_CWORD]}"     # Aktualnie wpisywane słowo
    prev="${COMP_WORDS[COMP_CWORD-1]}"  # Poprzednie słowo

    # Wczytanie zmiennych z konfiguracji bez modyfikowania obecnego środowiska
    local config_file="$HOME/.uctl/config"
    local proj_dir="$HOME/.uctl/projects"
    if [ -f "$config_file" ]; then
        local parsed_dir=$(grep '^UCTL_PROJECTS_DIR=' "$config_file" | cut -d'=' -f2 | tr -d '"' | tr -d "'")
        proj_dir="${parsed_dir/\$HOME/$HOME}"
    fi

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

    # POZIOM 2: Dynamiczne autouzupełnianie argumentów dla wszystkich modułów
    if [ "$COMP_CWORD" -eq 2 ]; then
        module="${COMP_WORDS[1]}"
        local projects=""
        local target_dir="$proj_dir/$module"
        
        # Automatycznie szuka podfolderów w katalogu przypisanym do modułu
        # np. uctl python -> szuka w ~/.uctl/projects/python/
        # np. uctl esp    -> szuka w ~/.uctl/projects/esp/
        if [ -d "$target_dir" ]; then
            for d in "$target_dir/"*/; do
                [ -d "$d" ] || continue
                proj_name=$(basename "$d")
                projects="$projects $proj_name"
            done
        fi
        
        # Ręczne wyjątki
        if [ "$module" == "config" ]; then
            projects="edit"
        fi
        
        COMPREPLY=( $(compgen -W "${projects}" -- "${cur}") )
        return 0
    fi
}

complete -F _uctl_completions uctl
EOF

# 4. Generowanie zaktualizowanych modułów rdzeniowych frameworka
echo "[*] Generowanie modułów rdzeniowych (config, edit, python)..."

# ---> Moduł: config <---
cat << 'EOF' > "$MODULES_DIR/config.sh"
#!/bin/bash
# Moduł: config

BLUE='\033[0;34m'
NC='\033[0m'
CONFIG_FILE="$HOME/.uctl/config"

if [ "$1" == "edit" ]; then
    EDITOR_CMD="${UCTL_DEFAULT_EDITOR:-vim}"
    $EDITOR_CMD "$CONFIG_FILE"
    echo -e "${BLUE}[*] Zapisano konfigurację.${NC}"
else
    echo -e "${BLUE}=== Aktualna konfiguracja uctl ===${NC}"
    cat "$CONFIG_FILE"
    echo -e "${BLUE}==================================${NC}"
    echo "Użycie: uctl config edit (aby zmienić)"
fi
EOF
chmod +x "$MODULES_DIR/config.sh"

# ---> Moduł: edit <---
cat << 'EOF' > "$MODULES_DIR/edit.sh"
#!/bin/bash
# Moduł: edit

TARGET_MODULE="$1"

if [ -z "$TARGET_MODULE" ]; then
    echo "Użycie: uctl edit <nazwa_modulu>"
    exit 1
fi

MODULES_DIR="$HOME/.uctl/modules"
MODULE_PATH="$MODULES_DIR/${TARGET_MODULE}.sh"

if [ ! -f "$MODULE_PATH" ]; then
    echo '#!/bin/bash' > "$MODULE_PATH"
    echo '' >> "$MODULE_PATH"
    echo "# Moduł: $TARGET_MODULE" >> "$MODULE_PATH"
    echo "# Zmienne globalne (np. \$UCTL_PROJECTS_DIR) są dostępne dzięki routerowi." >> "$MODULE_PATH"
    echo '' >> "$MODULE_PATH"
    chmod +x "$MODULE_PATH"
    echo "[+] Utworzono nowy moduł frameworka: $TARGET_MODULE"
else
    echo "[*] Edycja istniejącego modułu: $TARGET_MODULE"
fi

EDITOR_CMD="${UCTL_DEFAULT_EDITOR:-vim}"
$EDITOR_CMD "$MODULE_PATH"
EOF
chmod +x "$MODULES_DIR/edit.sh"

# ---> Moduł: python <---
cat << 'EOF' > "$MODULES_DIR/python.sh"
#!/bin/bash
# Moduł: python

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

PROJECT_NAME="$1"

if [ -z "$PROJECT_NAME" ]; then
    echo -e "${BLUE}Moduł: Python Workspace${NC}"
    echo "Użycie: uctl python <nazwa_projektu>"
    exit 1
fi

PROJECTS_DIR="${UCTL_PROJECTS_DIR:-$HOME/.uctl/projects}/python"
PROJECT_PATH="$PROJECTS_DIR/$PROJECT_NAME"

if [ -d "$PROJECT_PATH" ]; then
    echo -e "${GREEN}[*] Projekt '$PROJECT_NAME' istnieje.${NC}"
    echo -e "${BLUE}[*] Otwieranie środowiska pracy... (wpisz 'exit', aby wrócić)${NC}"
    exec bash --rcfile <(echo "source ~/.bashrc; cd '$PROJECT_PATH'; source venv/bin/activate")
fi

echo -e "${BLUE}[*] Tworzenie nowej struktury projektu w: $PROJECT_PATH${NC}"
mkdir -p "$PROJECT_PATH/src"
cd "$PROJECT_PATH" || exit

echo -e "${BLUE}[*] Inicjalizacja wirtualnego środowiska (venv)...${NC}"
if ! python3 -m venv venv; then
    echo -e "${RED}Błąd: Nie udało się utworzyć venv.${NC}"
    exit 1
fi

echo -e "${BLUE}[*] Generowanie plików bazowych...${NC}"

cat << 'INNER_EOF' > .gitignore
venv/
env/
__pycache__/
*.pyc
INNER_EOF

touch requirements.txt

cat << 'INNER_EOF' > src/main.py
#!/usr/bin/env python3
import sys

def main():
    print("Witaj w nowym projekcie Python!")

if __name__ == "__main__":
    main()
INNER_EOF

chmod +x src/main.py

echo -e "\n${GREEN}[+] Projekt '$PROJECT_NAME' jest gotowy!${NC}"
echo -e "${BLUE}[*] Przenoszenie do środowiska projektu... (wpisz 'exit', aby wrócić)${NC}"

exec bash --rcfile <(echo "source ~/.bashrc; cd '$PROJECT_PATH'; source venv/bin/activate")
EOF
chmod +x "$MODULES_DIR/python.sh"


# 5. Konfiguracja ~/.bashrc
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
    echo "[+] Podpięto inteligentne autouzupełnianie (klawisz Tab)."
fi

echo -e "\n[+] Instalacja zakończona! Przeładuj terminal komendą: source ~/.bashrc"
