#!/bin/sh
#
# 20-container-start.sh
# -----------
# Starts the Borg server container via systemd.
#
# Usage:
#   ./scripts/20-container-start.sh
#
# Example:
#   ./scripts/20-container-start.sh
#

echo "[start] Starting Borg server..."
systemctl --user start container-borg-server.service
echo "[start] Done."
