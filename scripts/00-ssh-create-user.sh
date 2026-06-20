#!/bin/sh
#
# 00-ssh-create-user.sh
# ---------------------
# Creates a new Borg client:
#  - Repository directory on the host
#  - Entry in config/clients.conf
#  - Empty public key file in config/keys/
#
# Usage:
#   ./scripts/00-ssh-create-user.sh <username> <group> <quota>
#
# Groups:
#   OWN     internal users from own network
#   MIRROR  external users (e.g. friends)
#
# Quota:
#   Format: <number>G (e.g. 10G, 50G, 200G)
#

set -e
#load setup for all scripts
. "$(dirname "$0")/config.sh"

if [ $# -ne 3 ]; then
    echo "Usage: $0 <username> <group> <quota>"
    echo "Group: OWN | MIRROR"
    echo "Quota format: <number>G (e.g. 50G)"
    exit 1
fi

USERNAME="$1"
GROUP="$2"
QUOTA="$3"

mkdir -p "$(dirname "$CONF")"
touch "$CONF"

case "$USERNAME" in
    *[!a-zA-Z0-9_-]*) echo "ERROR: Invalid username '$USERNAME' (only a-z, 0-9, _, - allowed)"; exit 1 ;;
esac

# validate group
if [ "$GROUP" != "OWN" ] && [ "$GROUP" != "MIRROR" ]; then
    echo "ERROR: unknown group '$GROUP'"
    echo "required: OWN | MIRROR"
    exit 1
fi

# validate quota (mandatory, format: <digits>G, e.g. 50G)
case "$QUOTA" in
    *[!0-9G]*|"")
        echo "ERROR: invalid quota format '$QUOTA' (expected: <number>G, e.g. 50G)"
        exit 1
        ;;
esac
case "$QUOTA" in
    *G) ;;
    *)
        echo "ERROR: invalid quota format '$QUOTA' (expected: <number>G, e.g. 50G)"
        exit 1
        ;;
esac

# autogenerate repo path
REPO_SUBPATH="${GROUP}/${USERNAME}"
CONTAINER_REPO="/repo/${REPO_SUBPATH}"

# check if user exists
if grep -q "^${USERNAME}:" "$CONF"; then
    echo "ERROR: User '$USERNAME' already exists in clients.conf! Aborted."
    exit 1
fi

echo "[create] Create entry in clients.conf"
echo "${USERNAME}:${GROUP}:${CONTAINER_REPO}:${QUOTA}" >> "$CONF"

echo "[create] Create empty public key file"
mkdir -p "$KEYDIR"
touch "${KEYDIR}/${USERNAME}.pub"

echo "[create] User '$USERNAME' created with quota $QUOTA."
echo "→ Set now the public key!"
