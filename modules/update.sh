#!/bin/bash

# Moduł: update
# Dostęp do argumentów wywołania poprzez $1, $2, itd.

# Kolory
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${BLUE}[*] Rozpoczynam pełną aktualizację systemu...${NC}\n"

echo -e "${BLUE}=== [1/4] Odświeżanie repozytoriów (apt update) ===${NC}"
sudo apt update

echo -e "\n${BLUE}=== [2/4] Instalacja aktualizacji (apt upgrade) ===${NC}"
sudo apt upgrade -y

echo -e "\n${BLUE}=== [3/4] Usuwanie osieroconych pakietów (apt autoremove) ===${NC}"
sudo apt autoremove -y

echo -e "\n${BLUE}=== [4/4] Czyszczenie pamięci podręcznej (apt autoclean) ===${NC}"
sudo apt autoclean -y

echo -e "\n${GREEN}[+] System został pomyślnie zaktualizowany i oczyszczony!${NC}"
