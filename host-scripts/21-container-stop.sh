#!/bin/sh
#
# 21-container-stop.sh
# ----------
# Stops the Borg server container via systemd.
#
# Usage:
#   ./scripts/21-container-stop.sh
#
# Example:
#   ./scripts/21-container-stop.sh
#

echo "[stop] Stopping Borg server..."
systemctl --user stop container-borg-server.service
echo "[stop] Done."
