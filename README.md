# borg-server

Container for a BorgBackup server based on Debian.

## Features

- Based on `debian:stable-slim` and `borgbackup`
- All archives are append-only for data integrity
- User accounts for each machine with SSH keys
- Secure SSH access (root login disabled, password login disabled)
- Designed for Podman/Docker + systemd environments
- Configurable volumes for repositories, logs, and configuration
- Accepts backups from machines in the local network
- Accepts mirrored backups from external server via tunneled connections (e.g., WireGuard), preferably encrypted

## Future Features

- Mirroring own backups to an external server with encryption

## Configuration

You can optionally set the UID and GID of the `borg` user inside the container by using the environment variables:

- `PUID` – user ID (default: `1111`)
- `PGID` – group ID (default: `1111`)

Example:

```bash id="fkl4sm"
podman run \
  --name=borgserver \
  --rm \
  -e PUID=1111 \
  -e PGID=1111 \
  --publish=2222:22 \
  --volume=$HOME/containers/borgbackup/config:/config:Z \
  --volume=$Home/containers/borgbackup/repo:/repo:Z \
  --volume=$HOME/containers/borgbackup/log:/log:Z \
  --volume=$HOME/containers/borgbackup/data:/data:Z \
  ghcr.io/raykhoefemann/borg-server:0.1
