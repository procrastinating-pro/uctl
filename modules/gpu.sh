#!/bin/bash
# Moduł: gpu

# Kolory
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Jeśli nie podano argumentu
if [ -z "$1" ]; then
    echo -e "${BLUE}Moduł: NVIDIA PRIME Offload${NC}"
    echo "Użycie: uctl gpu <program> [argumenty...]"
    echo "Przykład: uctl gpu blender"
    echo "Przykład: uctl gpu glxgears -info"
    exit 1
fi

PROGRAM="$1"

# Sprawdzenie, czy program w ogóle istnieje (nie dotyczy ścieżek bezwzględnych jak ./skrypt)
if ! command -v "$PROGRAM" &> /dev/null && [ ! -x "$PROGRAM" ]; then
    echo -e "${RED}Błąd: Nie znaleziono programu '$PROGRAM' w systemie.${NC}"
    exit 1
fi

echo -e "${GREEN}[*] Uruchamianie '$PROGRAM' na dedykowanej karcie NVIDIA...${NC}"

# Ustawienie zmiennych środowiskowych dla renderowania przez NVIDIA
export __NV_PRIME_RENDER_OFFLOAD=1
export __GLX_VENDOR_LIBRARY_NAME=nvidia
export __VK_LAYER_NV_optimus=NVIDIA_only  # Dodane dla kompatybilności z aplikacjami Vulkan

# Uruchomienie programu ze wszystkimi podanymi argumentami ("$@")
# 'exec' zastępuje obecny proces basha procesem uruchamianego programu
exec "$@"
