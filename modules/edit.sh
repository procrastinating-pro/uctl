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
