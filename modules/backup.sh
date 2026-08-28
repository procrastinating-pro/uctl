#!/bin/bash
# Moduł: backup

# Kolory
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Pobieranie listy argumentów (co chcemy spakować)
TARGETS=("$@")

if [ ${#TARGETS[@]} -eq 0 ]; then
    echo -e "${BLUE}Moduł: Backup na USB${NC}"
    echo "Użycie: uctl backup <plik_lub_folder1> [plik_lub_folder2 ...]"
    echo "Przykład: uctl backup ~/Projects/Cyberpunk-NetVis ~/.bashrc"
    exit 1
fi

# Sprawdzenie dostępnych pendrive'ów (zazwyczaj montowane w /media/$USER/)
MOUNT_DIR="/media/$USER"

if [ ! -d "$MOUNT_DIR" ]; then
    echo -e "${RED}Błąd: Katalog $MOUNT_DIR nie istnieje. Brak zamontowanych nośników.${NC}"
    exit 1
fi

# Zapisanie znalezionych folderów (nośników) do tablicy
mapfile -t DRIVES < <(find "$MOUNT_DIR" -mindepth 1 -maxdepth 1 -type d)

if [ ${#DRIVES[@]} -eq 0 ]; then
    echo -e "${RED}Błąd: Nie znaleziono żadnych zamontowanych pendrive'ów w systemie.${NC}"
    echo "Upewnij się, że pendrive jest podłączony."
    exit 1
fi

echo -e "${BLUE}[*] Znaleziono podłączone nośniki USB:${NC}"
for i in "${!DRIVES[@]}"; do
    # Wyświetlamy tylko końcową nazwę nośnika dla czytelności
    DRIVE_NAME=$(basename "${DRIVES[$i]}")
    echo "  [$i] $DRIVE_NAME"
done

echo ""
read -p "Wybierz numer nośnika docelowego (0-$(( ${#DRIVES[@]} - 1 ))): " SELECTION

# Walidacja wyboru
if ! [[ "$SELECTION" =~ ^[0-9]+$ ]] || [ "$SELECTION" -lt 0 ] || [ "$SELECTION" -ge "${#DRIVES[@]}" ]; then
    echo -e "${RED}Błąd: Nieprawidłowy wybór.${NC}"
    exit 1
fi

DEST_DRIVE="${DRIVES[$SELECTION]}"

# Generowanie nazwy pliku backupu z aktualną datą i godziną
DATE_STR=$(date +%F_%H-%M-%S)
BACKUP_NAME="backup_${DATE_STR}.tar.gz"
BACKUP_PATH="$DEST_DRIVE/$BACKUP_NAME"

echo -e "\n${BLUE}[*] Rozpoczynam pakowanie...${NC}"
echo "    Z: ${TARGETS[*]}"
echo "    Do: $BACKUP_PATH"
echo "------------------------------------------------------"

# Wykonanie kompresji (flagi: c - create, z - gzip, v - verbose, f - file)
tar -czvf "$BACKUP_PATH" "${TARGETS[@]}"

if [ $? -eq 0 ]; then
    echo -e "\n${GREEN}[+] Sukces! Backup zapisany na pendrive w: $BACKUP_PATH${NC}"
else
    echo -e "\n${RED}[-] Wystąpił błąd podczas tworzenia backupu. Sprawdź, czy ścieżki są poprawne i czy masz miejsce na USB.${NC}"
fi

