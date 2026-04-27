# borg-server

**Minimal, security-focused BorgBackup server for multi-client environments**

borg-server is a lightweight server wrapper around BorgBackup designed to receive backups from multiple clients while maintaining a minimal attack surface.

It intentionally avoids unnecessary complexity such as web interfaces or orchestration layers, focusing instead on secure, predictable, and transparent behavior.

---

## ✨ Features

- 🔒 **Security-first design**  
  Minimal attack surface, no web interface, no unnecessary services

- 👥 **Multi-client support**  
  Multiple users and devices can push backups to the same server

- 🗂️ **Repository isolation**  
  Logical separation of client backups (depending on configuration)

- 🔁 **Mirror backup ingestion**  
  Accept backups from other servers (offsite / redundancy setups)

- ⚙️ **Fully config-driven**  
  All behavior defined via simple configuration files

- 🧪 **Safe testing environment**  
  Designed to test backup strategies before production deployment

- 📝 **Centralized logging**  
  Logs stored locally in `/log`

- 🚫 **No orchestration layer**  
  No scheduling, no automation magic — stays transparent and predictable
---

## 🎯 Design Goals

- **Minimal attack surface**  
  No web UI, no exposed services beyond what is strictly required.

- **Explicit configuration**  
  All behavior is defined via config files — no hidden automation.

- **Server-side focus**  
  Handles backup ingestion, not client orchestration.

- **Security over convenience**  
  Designed for environments where backups are critical assets.

---

## 🛡️ Core Principles & Implementation Details

borg-server is built around a strict and opinionated setup to maximize security and reliability:

- **Base system**  
  Built on `debian:stable-slim` with `borgbackup` installed  
  → minimal, well-maintained, predictable environment

- **Append-only repositories**  
  All Borg repositories are configured as append-only  
  → existing backups cannot be modified or deleted

- **Per-client user isolation**  
  Each machine uses its own system user and SSH key  
  → strict separation between clients

- **Hardened SSH setup**  
  - root login disabled  
  - password authentication disabled  
  → access only via SSH keys

- **Container-first deployment**  
  Designed for use with Podman or Docker  
  → integrates cleanly into systemd-based environments

- **Strict volume separation**  
  Configurable mount points for:
  - repositories
  - logs
  - configuration  
  → clear separation of concerns and easier hardening

- **Local network backup ingestion**  
  Accepts backups from trusted machines inside a local network

- **Mirror / offsite backup support**  
  Accepts backups from external servers for redundancy setups

  Recommended practices:
  - client-side encryption (Borg) for maximum privacy  
  - tunneled connections (e.g. WireGuard)  
  - expose only SSH port if external access is required  
## 🧱 Architecture Overview

## Future Features

- Mirroring your backups to another server, such as an external host, with local encryption for maximum privacy

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


- **`$HOME/containers/borg-server/config:/config:Z`** – Mounts the local `config` directory to the container’s `/config` directory. The `Z` option ensures that SELinux-compatible permissions are set.
- **`$HOME/containers/borg-server/repo:/repo:Z`** – Mounts the local `repo` directory to the container’s `/repo`, where all backup data will be stored.
- **`$HOME/containers/borg-server/log:/log:Z`** – Mounts the local `log` directory to the container’s `/log`, where log files will be stored.

### Example Command:

```bash
podman run \
--name=borg-server \
--rm \
-e PUID=1111 \
-e PGID=1111 \
--publish=2222:22 \
--volume=$HOME/containers/borg-server/config:/config:Z \
--volume=$HOME/containers/borg-server/repo:/repo:Z \
--volume=$HOME/containers/borg-server/log:/log:Z \
ghcr.io/raykhoefemann/borg-server:0.1
