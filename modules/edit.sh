#!/bin/bash

# $1 to nazwa nowego/edytowanego modułu uctl
TARGET_MODULE="$1"

if [ -z "$TARGET_MODULE" ]; then
    echo "Użycie: uctl edit <nazwa_modulu>"
    exit 1
fi

MODULES_DIR="$HOME/.uctl/modules"
MODULE_PATH="$MODULES_DIR/${TARGET_MODULE}.sh"

# Zabezpieczenie przed edycją samego siebie z poziomu vima w dziwny sposób,
# chociaż technicznie jest to możliwe.
if [ ! -f "$MODULE_PATH" ]; then
    echo '#!/bin/bash' > "$MODULE_PATH"
    echo '' >> "$MODULE_PATH"
    echo "# Moduł: $TARGET_MODULE" >> "$MODULE_PATH"
    echo "# Dostęp do argumentów wywołania poprzez \$1, \$2, itd." >> "$MODULE_PATH"
    echo '' >> "$MODULE_PATH"
    chmod +x "$MODULE_PATH"
    echo "[+] Utworzono nowy moduł frameworka: $TARGET_MODULE"
else
    echo "[*] Edycja istniejącego modułu: $TARGET_MODULE"
fi

vim "$MODULE_PATH"
