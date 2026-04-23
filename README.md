# borg-server

**ATTENTION: Currently not working!!!**  
Podman container for a BorgBackup server based on Debian, with Fedora CoreOS as the host.

## Features

- Based on `debian:stable-slim` and `borgbackup`
- All archives are append-only for maximum data integrity (modifying and deleting are forbidden)
- User accounts for each machine with SSH keys
- Secure SSH access (root login disabled, password login disabled)
- Designed for Podman/Docker + systemd environments
- Configurable volumes for repositories, logs, and configuration
- Accepts backups from your own machines in the local network
- Accepts mirrored backups from external servers via tunneled connections (e.g., WireGuard), preferably encrypted for maximum privacy

## Future Features

- Mirroring your own backups to an external server with local encryption for maximum privacy

## Configuration

When starting the container, various environment variables and parameters can be set to customize the configuration. Below are all available parameters and their descriptions:

### Environment Variables:

- **`PUID`** – **User ID**  
  Sets the user ID (UID) for the `borg` user inside the container. By default, this is set to `1111`. This is important if you need to access the backup directories and ensure the permissions align with your system user.

  **Example**: `PUID=1000` – Sets the UID of the `borg` user inside the container to `1000` (usually the default for the first user on a Linux system).

- **`PGID`** – **Group ID**  
  Sets the group ID (GID) for the `borg` user's group inside the container. By default, this is also set to `1111`. As with the UID, it’s important to set the GID correctly to synchronize file access permissions with your system.

  **Example**: `PGID=1000` – Sets the GID of the `borg` user inside the container to `1000`.

### Container Options:

- **`--name`** – **Container Name**  
  Sets the name of the container. This can be helpful to identify the container later, especially if multiple containers are running.

  **Example**: `--name=borg-server` – Sets the name of the container to `borg-server`.

- **`--rm`** – **Remove Container After Exit**  
  This option ensures that the container is automatically removed when it stops. Useful for one-time tasks like backup jobs, where you don't need the container to persist after it’s done.

- **`--publish`** – **Port Forwarding**  
  This option forwards a local port to a port inside the container. In this case, it forwards the SSH port `2222` on the host to port `22` inside the container.

  **Example**: `--publish=2222:22` – Forwards local port `2222` to port `22` inside the container (the default SSH port).

- **`--volume`** – **Volume Mounts**  
  This option mounts local directories or files to the container. It’s essential to persist data, such as backup repositories, configuration files, or log files. The format is:
  `--volume=<local-path>:<container-path>:<options>`


- **`$HOME/containers/borgbackup/config:/config:Z`** – Mounts the local `config` directory to the container’s `/config` directory. The `Z` option ensures that SELinux-compatible permissions are set.
- **`$HOME/containers/borgbackup/repo:/repo:Z`** – Mounts the local `repo` directory to the container’s `/repo`, where all backup data will be stored.
- **`$HOME/containers/borgbackup/log:/log:Z`** – Mounts the local `log` directory to the container’s `/log`, where log files will be stored.

### Example Command:

```bash
podman run \
--name=borg-server \
--rm \
-e PUID=1111 \
-e PGID=1111 \
--publish=2222:22 \
--volume=$HOME/containers/borgbackup/config:/config:Z \
--volume=$HOME/containers/borgbackup/repo:/repo:Z \
--volume=$HOME/containers/borgbackup/log:/log:Z \
ghcr.io/raykhoefemann/borg-server:0.1
