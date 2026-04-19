#!/bin/sh
#
# entrypoint.sh
# --------------
# Start-Script für den Borg-Backup-Container.
#
# Aufgaben:
#   - SSH-Hostkeys erzeugen (falls nicht vorhanden)
#   - .ssh-Verzeichnis für den Benutzer 'borg' vorbereiten
#   - authorized_keys aus /config/clients.conf generieren
#     (über /config/build_authorized_keys.sh)
#   - Rechte korrigieren
#   - SSH-Daemon starten
#

set -e

echo "[entrypoint] Starte Borg-Server..."

# ---------------------------------------------------------
# SSH Hostkeys erzeugen (falls noch nicht vorhanden)
# ---------------------------------------------------------
echo "[entrypoint] Erzeuge SSH-Hostkeys (falls nötig)..."
ssh-keygen -A

# ---------------------------------------------------------
# .ssh-Verzeichnis für Benutzer 'borg' vorbereiten
# ---------------------------------------------------------
echo "[entrypoint] Bereite /home/borg/.ssh vor..."
mkdir -p /home/borg/.ssh
chmod 700 /home/borg/.ssh
chown borg:borg /home/borg/.ssh

# ---------------------------------------------------------
# authorized_keys generieren
# ---------------------------------------------------------
if [ -f /build_authorized_keys.sh ]; then
    echo "[entrypoint] Generiere authorized_keys aus clients.conf..."
    /build_authorized_keys.sh
else
    echo "[entrypoint] WARNUNG: /build_authorized_keys.sh nicht gefunden!"
    echo "[entrypoint] SSH-Login wird NICHT funktionieren!"
fi

# ---------------------------------------------------------
# Repo-Besitz korrigieren
# ---------------------------------------------------------
echo "[entrypoint] Setze Besitzerrechte für /repo..."
chown -R borg:borg /repo

# ---------------------------------------------------------
# SSH starten
# ---------------------------------------------------------
echo "[entrypoint] Starte SSH-Daemon..."
exec /usr/sbin/sshd -D -e
