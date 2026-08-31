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
