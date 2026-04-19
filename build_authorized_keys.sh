#!/bin/sh
#
# build_authorized_keys.sh
# ------------------------
# Erzeugt die Datei /home/borg/.ssh/authorized_keys basierend auf:
#   /config/clients.conf  (Format: name::group::repo::mode)
#   /config/keys/<name>.pub
#

CONF="/config/clients.conf"
KEYDIR="/config/keys"
OUT="/home/borg/.ssh/authorized_keys"

# Header
echo "# Auto-generated authorized_keys" > "$OUT"
echo "# Do not edit manually" >> "$OUT"
echo "" >> "$OUT"

# Jede Zeile aus clients.conf lesen
while IFS="::" read -r name group repo mode; do
    # Leere Zeilen oder Kommentare überspringen
    [ -z "$name" ] && continue
    echo "$name" | grep -q "^#" && continue

    KEYFILE="${KEYDIR}/${name}.pub"

    if [ ! -f "$KEYFILE" ]; then
        echo "[WARN] Kein Public Key für '$name' gefunden – überspringe" >&2
        continue
    fi

    key="$(cat "$KEYFILE")"

    # Forced command abhängig vom Modus
    if [ "$mode" = "append-only" ]; then
        CMD="borg serve --restrict-to-path $repo --append-only"
    else
        CMD="borg serve --restrict-to-path $repo"
    fi

    # authorized_keys-Eintrag erzeugen
    echo "command=\"$CMD\",restrict $key" >> "$OUT"

done < "$CONF"

# Rechte setzen
chown borg:borg "$OUT"
chmod 600 "$OUT"
