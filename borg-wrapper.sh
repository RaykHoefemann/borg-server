#!/bin/bash
set -euo pipefail

REPO="$1"
CONFIG="$REPO/config"

if ! echo "$REPO" | grep -qE '^/[a-zA-Z0-9/_-]+$'; then
    echo "DENY: invalid repo path" >&2
    exit 1
fi

# Fall 1: Verzeichnis existiert nicht oder ist komplett leer
# -> noch nie initialisiert, Client darf "borg init" ausführen
if [ ! -e "$REPO" ] || [ -z "$(ls -A "$REPO" 2>/dev/null)" ]; then
    mkdir -p "$REPO"
    exec borg serve --restrict-to-path "$REPO" --append-only
fi

# Fall 2: Verzeichnis existiert und hat Inhalt, aber config fehlt
# -> verdächtig (Korruption, manuelle Löschung, etc.), NICHT automatisch erlauben
if [ ! -f "$CONFIG" ]; then
    echo "DENY: repo non-empty but config missing – needs manual admin review" >&2
    exit 1
fi

# Fall 3: Normalbetrieb – config vorhanden, Verschlüsselung prüfen
MODE=$(grep "^encryption" "$CONFIG" | head -n1 | cut -d= -f2 | tr -d ' ')

case "$MODE" in
    repokey*|keyfile*) ;;
    none|"")
        echo "DENY: unencrypted repository" >&2
        exit 1
        ;;
    *)
        echo "DENY: unknown encryption mode: $MODE" >&2
        exit 1
        ;;
esac

exec borg serve --restrict-to-path "$REPO" --append-only
