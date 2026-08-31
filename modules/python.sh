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
