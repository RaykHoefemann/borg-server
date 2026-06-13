#!/bin/sh
#
# borg-wrapper.sh
# ---------------
# Wrapper for borg serve.
# Rejects and deletes unencrypted repositories.
#
REPO="$1"

if [ -f "$REPO/config" ]; then
    MODE=$(grep "^encryption" "$REPO/config" | cut -d= -f2 | tr -d ' ')
    if [ "$MODE" = "none" ]; then
        echo "ERROR: Unencrypted repository rejected and deleted." >&2
        rm -rf "$REPO"
        exit 1
    fi
fi

exec borg serve --restrict-to-path "$REPO" --append-only
