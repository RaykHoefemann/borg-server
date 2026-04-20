#!/bin/sh
#
# entrypoint.sh
# --------------
# Startup script for the Borg backup container.
#
# Tasks:
#   - Generate SSH host keys (if not present)
#   - Prepare the .ssh directory for the 'borg' user
#   - Generate authorized_keys from /config/clients.conf
#     (via /config/build_authorized_keys.sh)
#   - Fix permissions
#   - Start the SSH daemon
#

set -e

echo "[entrypoint] Starting Borg server..."

# ---------------------------------------------------------
# Generate SSH host keys (if not already present)
# ---------------------------------------------------------
echo "[entrypoint] Generating SSH host keys (if needed)..."
ssh-keygen -A

# ---------------------------------------------------------
# Prepare .ssh directory for user 'borg'
# ---------------------------------------------------------
echo "[entrypoint] Preparing /home/borg/.ssh..."
mkdir -p /home/borg/.ssh
chmod 700 /home/borg/.ssh
chown borg:borg /home/borg/.ssh

# ---------------------------------------------------------
# Create authorized_keys
# ---------------------------------------------------------
if [ -f /build_authorized_keys.sh ]; then
    echo "[entrypoint] Create authorized_keys from clients.conf..."
    /build_authorized_keys.sh
else
    echo "[entrypoint] WARNING: /build_authorized_keys.sh not found!"
    echo "[entrypoint] SSH login will NOT work!"
fi

# ---------------------------------------------------------
# set owner of repo
# ---------------------------------------------------------
echo "[entrypoint] Setting owner of /repo..."
chown -R borg:borg /repo

# ---------------------------------------------------------
# start SSH
# ---------------------------------------------------------
echo "[entrypoint] Starting SSH-Daemon..."
exec /usr/sbin/sshd -D -e
