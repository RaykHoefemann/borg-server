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
LOG="/log/build_authorized_keys.log"

# Log Function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG"
}

# Header
log "# Starting the build of authorized_keys..."
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
        log "[WARN] No public key found for '$name' – will be skipped"
        continue
    fi

    key="$(cat "$KEYFILE")"

    # forced command with append-only
    CMD="borg serve --restrict-to-path $repo --append-only"

    # create new entry in authorized_keys
    echo "command=\"$CMD\",restrict $key" >> "$OUT"
    log "[INFO] Added authorized key for '$name' with repo '$repo'"

done < "$CONF"

# set permissions
chown borg:borg "$OUT"
chmod 600 "$OUT"
log "[INFO] Permissions set for $OUT"

log "done"
