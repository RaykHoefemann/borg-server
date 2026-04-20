#!/bin/sh
#
# build_authorized_keys.sh
# ------------------------
# create the file /home/borg/.ssh/authorized_keys based on:
#   /config/clients.conf  (Format: name:group:repo)
#   /config/keys/<name>.pub (public ssh-key from user)
#

CONF="/config/clients.conf"
KEYDIR="/config/keys"
OUT="/home/borg/.ssh/authorized_keys"

# Header
echo "# Auto-generated authorized_keys" > "$OUT"
echo "# Do not edit manually" >> "$OUT"
echo "" >> "$OUT"

# read each line from clients.conf
while IFS="::" read -r name group repo mode; do
    # skip empty lines and comments
    [ -z "$name" ] && continue
    echo "$name" | grep -q "^#" && continue

    KEYFILE="${KEYDIR}/${name}.pub"

    if [ ! -f "$KEYFILE" ]; then
        echo "[WARN] No public key found for '$name' – will be skipped" >&2
        continue
    fi

    key="$(cat "$KEYFILE")"

    # forced command with append-only
    CMD="borg serve --restrict-to-path $repo --append-only"

    # create new entry in authorized_keys
    echo "command=\"$CMD\",restrict $key" >> "$OUT"

done < "$CONF"

# set permissions
chown borg:borg "$OUT"
chmod 600 "$OUT"
