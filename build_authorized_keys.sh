#!/bin/bash
#
# build_authorized_keys.sh
# ------------------------
# create the file /home/borg/.ssh/authorized_keys based on:
# /config/clients.conf (Format: name:group:repo)
# /config/keys/<name>.pub (public ssh-key from user)
#

set -euo pipefail

CONF="/config/clients.conf"
KEYDIR="/config/keys"
OUT="/home/borg/.ssh/authorized_keys"
TMPOUT="${OUT}.tmp"
LOG="/log/build_authorized_keys.log"

# Log Function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG"
}

# sanity checks
if [ ! -f "$CONF" ]; then
    log "[ERROR] Config file $CONF not found – aborting"
    exit 1
fi

if [ ! -d "$KEYDIR" ]; then
    log "[ERROR] Key directory $KEYDIR not found – aborting"
    exit 1
fi

if [ ! -d "$(dirname "$OUT")" ]; then
    log "[ERROR] Target directory $(dirname "$OUT") not found – aborting"
    exit 1
fi

# Header (write to tempfile, not directly to $OUT)
log "# Starting the build of authorized_keys..."
echo "# Auto-generated authorized_keys" > "$TMPOUT"
echo "# Do not edit manually" >> "$TMPOUT"
echo "" >> "$TMPOUT"

count=0

# read each line from clients.conf
while IFS=":" read -r name group repo; do
    [ -z "$name" ] && continue

    case "$name" in
        \#*) continue ;;
    esac

    # Validate name (used in file path)
    if ! echo "$name" | grep -qE '^[a-zA-Z0-9_-]+$'; then
        log "[ERROR] Invalid name '$name' – skipping"
        continue
    fi

    # Validate group
    if ! echo "$group" | grep -qE '^[a-zA-Z0-9_-]+$'; then
        log "[ERROR] Invalid group '$group' for '$name' – skipping"
        continue
    fi

    # Validate repo path (used in forced command)
    if ! echo "$repo" | grep -qE '^/[a-zA-Z0-9/_-]+$'; then
        log "[ERROR] Invalid repo path for '$name': '$repo' – skipping"
        continue
    fi

    log "[INFO] Found user: '$name'"

    KEYFILE="${KEYDIR}/${name}.pub"

    if [ ! -f "$KEYFILE" ]; then
        log "[WARN] No public key found for '$name' – skipping"
        continue
    fi

    if [ ! -s "$KEYFILE" ]; then
        log "[WARN] Public key file for '$name' is empty – skipping"
        continue
    fi

    # Validate SSH key
    if ! ssh-keygen -l -f "$KEYFILE" > /dev/null 2>&1; then
        log "[ERROR] Invalid SSH key for '$name' – skipping"
        continue
    fi

    # Use only the first line – prevents multi-line key files
    # from injecting additional entries that bypass command= or restrict options
    key="$(head -n1 "$KEYFILE")"

    CMD="/borg-wrapper.sh $repo"
    echo "command=\"$CMD\",restrict $key" >> "$TMPOUT"

    log "[INFO] Added key for '$name' with repo '$repo'"
    count=$((count + 1))

done < "$CONF"

# Abort if no keys were successfully added
if [ "$count" -eq 0 ]; then
    log "[ERROR] No valid keys were added – authorized_keys would be empty! Keeping existing file."
    rm -f "$TMPOUT"
    exit 1
fi

# Atomic swap: replace authorized_keys only on success
mv "$TMPOUT" "$OUT"

# set permissions
chown borg:borg "$OUT"
chmod 600 "$OUT"

log "[INFO] Permissions set for $OUT"
log "[INFO] $count key(s) written to authorized_keys"
log "done"
