#!/bin/sh
#
# 23-container-restart.sh
# --------------
# Restarts the Borg server container.
# Must be executed when clients.conf has been modified.
#
# Usage:
#   ./scripts/23-container-restart.sh
#
# Example:
#   ./scripts/23-container-restart.sh
#

echo "[restart] Restarting Borg server..."
systemctl --user restart container-borg-server.service
echo "[restart] Done."
