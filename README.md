# borg-server

**Minimal, security-focused BorgBackup server for multi-client environments**

borg-server is a lightweight server wrapper around BorgBackup designed to receive backups from multiple clients while maintaining a minimal attack surface.  
It intentionally avoids unnecessary complexity such as web interfaces or orchestration layers, focusing instead on secure, predictable, and transparent behavior.

---

## ✨ Features

- 🔒 **Security-first design**  
  Minimal attack surface, no web interface, no unnecessary services.

- 👥 **Multi-client support**  
  Multiple users and devices can push backups to the same server.

- 🗂️ **Repository isolation**  
  Logical separation of client backups per configuration.

- 🔁 **Mirror backup ingestion**  
  Accept backups from other servers for offsite or redundancy setups.

- ⚙️ **Fully config-driven**  
  All behavior defined via simple configuration files.

- 🧪 **Safe testing environment**  
  Designed for testing backup strategies before production deployment.

- 📝 **Centralized logging**  
  Logs stored locally in `/log`.

- 🚫 **No orchestration layer**  
  No scheduling or automation magic — stays transparent and predictable.

---

## 🔐 Security Model

borg-server is built with a **strict security-first approach**, assuming that clients may be compromised.  
All critical security measures are enforced **server-side**.

### Access Control

- SSH key-based authentication only  
- Password authentication is disabled  
- Root login via SSH is disabled  
- Each client uses a dedicated system user

### Network Exposure

- No web interface  
- No HTTP API  
- SSH is the only entry point

### Isolation Model

- Each client is assigned a separate user context  
- Backup repositories are logically separated per client  
- Cross-client access is not permitted

### Immutable Storage (Append-Only Enforcement)

borg-server enforces **append-only mode server-side** for all repositories.  

Clients cannot disable or bypass this behavior.  
Even in case of a compromised client, it is impossible to:

- Modify existing backup archives  
- Delete historical backup data  
- Disable append-only protection

This guarantees that all stored backups are **immutable once written**.

### Threat Model

The system assumes:

- Clients may be compromised  
- Network connections may be partially untrusted  
- Only the server is trusted to enforce integrity rules

Consequently:

- All integrity guarantees are enforced server-side  
- Clients are treated as untrusted input sources  
- Backup history is treated as immutable storage

---

## 💡 Security & Best Practices

borg-server enforces strict server-side security measures (see Security Model above).  
However, secure operation also depends on proper configuration and operational practices by the administrator.

⚠️ **Important:** Please review the [Best Practices Guide](BEST_PRACTICES.md) for recommendations on secure usage, including:

- Encrypting backups before mirroring  
- Using tunneled connections for remote replication  
- Exposing only the necessary SSH port  
- Regular monitoring and verification of backups

---

## 🧱 Architecture Overview

- **Base system:** `debian:stable-slim` with `borgbackup` installed  
  Minimal, well-maintained, predictable environment.

- **Containerized deployment:** Podman/Docker + systemd integration  
  Optional but recommended for reproducibility and isolation.

- **Volumes:** Separate mounts for repositories, logs, and configuration  
  Ensures separation of concerns and easier hardening.

- **Backup flows:**  
  - Client → Server (local network or trusted connections)  
  - Server → Server (mirror/offsite replication)

---

## 🛠 Deployment & Configuration

### Environment Variables

- **`PUID`** – User ID inside the container (default `1111`)  
- **`PGID`** – Group ID inside the container (default `1111`)

### Container Options

- `--name` – Container name  
- `--rm` – Remove container after exit  
- `--publish` – Port forwarding (e.g., `2222:22` for SSH)  
- `--volume` – Volume mounts (config, repo, log)

### Example Command

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
