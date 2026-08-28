#!/bin/bash
# Moduł: setup

# Kolory dla czytelności
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}[*] Rozpoczynam konfigurację środowiska systemowego...${NC}"

# 1. Instalacja podstawowych narzędzi i środowisk
echo "[*] Aktualizacja repozytoriów i instalacja pakietów..."
sudo apt update
# Dodano python3-venv do listy pakietów
sudo apt install -y vim git curl wget build-essential python3-venv

# 2. Konfiguracja edytora Vim
echo "[*] Generowanie konfiguracji Vima (~/.vimrc)..."
VIMRC="$HOME/.vimrc"

if [ -f "$VIMRC" ]; then
    cp "$VIMRC" "${VIMRC}.backup_$(date +%F_%H-%M-%S)"
    echo "    (Utworzono kopię zapasową starego .vimrc)"
fi

cat << 'EOF' > "$VIMRC"
" ---------------------------------------------------
" Konfiguracja Vim (wygenerowana przez uctl setup)
" ---------------------------------------------------

syntax on
colorscheme slate
set cursorline
set number
set relativenumber

set tabstop=4
set shiftwidth=4
set expandtab
set autoindent
set smartindent

set hlsearch
set incsearch
EOF

echo -e "${GREEN}[+] Gotowe! System zaktualizowany (w tym python3-venv), a Vim gotowy do pracy.${NC}"
