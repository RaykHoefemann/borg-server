# -----------------------------------------------------------------------------
# BorgBackup Server Container (Debian-based)
#
# Dieses Image stellt einen vollständigen Borg-Server bereit, der per SSH
# erreichbar ist und dauerhaft läuft. Es basiert auf Debian, enthält BorgBackup
# und einen OpenSSH-Server, unterstützt append-only-Repositories und ist für den
# Einsatz unter Podman + systemd (z. B. auf Fedora CoreOS) optimiert.
#
# Kein WireGuard, kein Cron, kein Borgmatic – nur ein minimaler, stabiler,
# sicherer Borg-Server, der identisch zu deinem Debian-Testsetup funktioniert.
# -----------------------------------------------------------------------------

FROM debian:stable-slim

ENV DEBIAN_FRONTEND=noninteractive

# Basis-Pakete installieren
RUN apt-get update && apt-get install -y \
    borgbackup \
    openssh-server \
    && rm -rf /var/lib/apt/lists/*

# SSH vorbereiten
RUN mkdir -p /var/run/sshd

# Benutzer für Borg
ENV PUID=1111
ENV PGID=1111

RUN groupadd -g ${PGID} borg && \
    useradd -u ${PUID} -g ${PGID} -m -d /home/borg -s /bin/bash borg

# SSH-Verzeichnis vorbereiten
RUN mkdir -p /home/borg/.ssh && \
    chown -R borg:borg /home/borg/.ssh && \
    chmod 700 /home/borg/.ssh

# SSH-Config: root-Login deaktivieren, nur borg erlauben
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config && \
    echo "AllowUsers borg" >> /etc/ssh/sshd_config

# Skript 'build_authorized_keys.sh' ins Image kopieren
COPY build_authorized_keys.sh /build_authorized_keys.sh
RUN chmod +x /build_authorized_keys.sh

# EntryPoint-Script ins Image kopieren
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 22

ENTRYPOINT ["/entrypoint.sh"]
