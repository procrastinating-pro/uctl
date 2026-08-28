#!/bin/bash
# Moduł: gpu-setup

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}[*] Diagnostyka i automatyczna instalacja sterowników NVIDIA...${NC}"

if ! command -v ubuntu-drivers &> /dev/null; then
    echo "[*] Brakuje narzędzia ubuntu-drivers. Instalowanie..."
    sudo apt update && sudo apt install -y ubuntu-drivers-common
fi

echo "[*] Skanowanie sprzętu..."

GPU_MODEL=$(lspci | grep -i nvidia | grep -iE 'vga|3d' | head -n 1 | awk -F': ' '{print $2}')
if [ -z "$GPU_MODEL" ]; then
    GPU_MODEL="Nieznana (NVIDIA nie została wykryta przez lspci)"
fi

RECOMMENDED_DRIVER=$(ubuntu-drivers devices 2>/dev/null | grep "recommended" | awk '{print $3}')
if [ -z "$RECOMMENDED_DRIVER" ]; then
    echo -e "${RED}[-] Nie wykryto karty NVIDIA wymagającej własnościowych sterowników.${NC}"
    exit 1
fi

echo -e "\n${BLUE}=== Znaleziony Sprzęt ===${NC}"
echo -e " Karta graficzna: ${GREEN}${GPU_MODEL}${NC}"
echo -e " Sterownik:       ${GREEN}${RECOMMENDED_DRIVER}${NC}"
echo -e "${BLUE}=========================${NC}\n"

read -p "Czy sprzęt się zgadza i chcesz rozpocząć instalację? (T/n): " INSTALL_CHOICE
if [[ "$INSTALL_CHOICE" =~ ^[Nn]$ ]]; then
    echo -e "${RED}[*] Instalacja przerwana przez użytkownika.${NC}"
    exit 0
fi

echo -e "\n${BLUE}[*] Rozpoczynam pobieranie i instalację...${NC}"

sudo ubuntu-drivers autoinstall

if [ $? -eq 0 ]; then
    echo -e "\n${GREEN}[+] Sterowniki zostały zainstalowane pomyślnie!${NC}"
    
    # --- NOWA CZĘŚĆ: Konfiguracja NVIDIA Optimus (Prime) ---
    if command -v prime-select &> /dev/null; then
        echo -e "${BLUE}[*] Ustawianie trybu hybrydowego (NVIDIA On-Demand)...${NC}"
        sudo prime-select on-demand
        echo -e "${GREEN}[+] Tryb on-demand aktywny. Karta uruchomi się tylko z komendą 'uctl gpu'.${NC}"
    else
        echo -e "${BLUE}[*] Pominięto prime-select (narzędzie niedostępne w tym systemie).${NC}"
    fi
    # -------------------------------------------------------

    echo -e "${RED}[!] Aby moduły jądra zaczęły działać, MUSISZ zrestartować komputer.${NC}"
    
    read -p "Czy chcesz zrestartować system teraz? (T/n): " REBOOT_CHOICE
    if [[ -z "$REBOOT_CHOICE" || "$REBOOT_CHOICE" =~ ^[Tt]$ ]]; then
        echo "Restartowanie..."
        sudo reboot
    else
        echo "Pamiętaj o ręcznym zrestartowaniu systemu przed użyciem NVIDII!"
    fi
else
    echo -e "\n${RED}[-] Wystąpił błąd podczas instalacji. Sprawdź logi systemowe.${NC}"
fi
