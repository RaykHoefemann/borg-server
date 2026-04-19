# borg-server

Container for a BorgBackup server based on Debian.

## Features

- Based on `debian:stable-slim` and `borgbackup`
- All archives are append-only for data integrity
- User accounts for each machine with SSH keys
- Secure SSH access (root login disabled, password login disabled)
- Designed for Podman/Docker + systemd environments
- Configurable volumes for repositories, logs, and configuration

## Usage

### Start container with Podman

```bash
podman run \
  --name=borgbackup \
  --rm \
  --publish=2222:22 \
  --volume=$HOME/containers/borgbackup/config:/config:Z \
  --volume=/var/mnt/extern1/borgbackup:/repo:Z \
  --volume=$HOME/containers/borgbackup/log:/log:Z \
  --volume=$HOME/containers/borgbackup/data:/data:Z \
  ghcr.io/raykhoefemann/borg-server:0.1
