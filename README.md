# hardened-borg-server

**Security-hardened BorgBackup server for controlled multi-client backup environments**

hardened-borg-server is a minimal, security-focused server wrapper around BorgBackup designed to receive backups from multiple clients in a strictly controlled and hardened deployment environment.

It is intentionally designed to avoid unnecessary complexity such as web interfaces, orchestration layers, or multi-purpose APIs, focusing instead on a small, auditable and predictable security surface.

---

## 🔐 Security Model Overview

hardened-borg-server is built as part of a **defense-in-depth backup architecture** and assumes a strict separation between:

- the **application layer (this project)**
- the **host system (operator responsibility)**
- the **client systems (untrusted)**

### Trust Boundaries

- **Trusted:** hardened-borg-server runtime (containerized application layer)
- **Trusted (required):** hardened host environment (SELinux / rootless / isolation)
- **Untrusted:** all client systems and backup sources
- **Partially trusted:** network layer (protected via SSH, optionally VPN)

---

## 🛡️ Security Guarantees (with correct deployment)

When deployed according to the required baseline configuration (see `BEST_PRACTICES.md`), hardened-borg-server provides:

- Strict repository isolation between clients
- No shell access for backup clients (Borg-only execution context)
- Server-side enforced access control via forced commands
- Append-only backup semantics enforced at the server layer
- No cross-client data access via SSH restrictions
- Minimal exposed attack surface (SSH only)

These guarantees depend on correct host hardening and adherence to operational requirements.

---

## ✨ Features

- 🔒 **Security-hardened design**
  Minimal attack surface, no web interface, no orchestration layer.

- 👥 **Multi-client support**
  Multiple clients can securely push backups to a single server.

- 🗂️ **Strong repository isolation**
  Each client is mapped to a strictly separated repository path.

- 🔁 **Mirror / offsite ingestion support**
  Supports backup replication from other Borg servers.

- ⚙️ **Fully config-driven architecture**
  No hidden logic, all behavior explicitly defined in configuration.

- 🧪 **Safe testing mode**
  Enables validation of backup workflows before production usage.

- 📝 **Centralized logging**
  Local log storage under `/log`.

- 🚫 **No orchestration layer**
  No scheduling, no automation system — deterministic execution only.

---

## 🛡️ Security Model (Implementation Details)

### Threat Model

The system assumes:

- Client systems may be compromised
- Backup sources are untrusted
- Network connections may be intercepted or manipulated
- The server is the only enforcement point for backup integrity rules

---

### Access Control

- SSH key-based authentication only
- Password authentication disabled
- Root login disabled
- Dedicated SSH key per client
- Forced command execution prevents interactive shell access
- Each client is restricted to its own repository path
- Cross-client access is structurally impossible via configuration isolation

---

### SSH Hardening

- Only modern cryptographic algorithms enabled
- Legacy algorithms disabled
- Interactive features disabled (TTY, X11, forwarding, tunneling)
- Connection and authentication limits enforced
- SSH host keys are persisted across restarts to maintain stable identity

---

### Repository Enforcement

- Each client is mapped to an isolated repository path
- Access is enforced server-side via forced commands
- No direct filesystem-level access for clients
- Cross-repository access is not permitted

---

### Append-Only Semantics

The system enforces append-only behavior at the server layer.

Clients cannot:

- Modify existing backup archives
- Delete historical backup data
- Disable append-only enforcement

Only new backup data can be appended.

---

### Network Exposure

- No web interface
- No HTTP API
- SSH is the only external interface

---

## ⚠️ Deployment Requirements

hardened-borg-server is **not a standalone secure system**.

It is a security-enforcing component that MUST be deployed on a properly hardened host system.

### Required baseline (see `BEST_PRACTICES.md`)

Production deployments MUST follow all requirements defined in:

👉 `BEST_PRACTICES.md`

This includes:

- Encryption at source for backups
- Secure transport configuration (SSH, optional VPN tunneling)
- Minimal network exposure (only SSH)
- Regular integrity verification (borg check)
- Restore testing procedures
- Proper separation of repositories, logs, and configuration data

---

## 🧱 Architecture Overview

- **Base image:** `debian:stable-slim` with BorgBackup installed  
  Minimal and predictable runtime environment.

- **Runtime:** Containerized (Podman or Docker recommended)  
  Rootless execution strongly recommended for additional isolation.

- **Host integration:** systemd-compatible deployment supported

- **Storage model:**
  - Separate volumes for repositories
  - Separate volumes for logs
  - Separate volumes for configuration

- **Backup flows:**
  - Client → Server (SSH / optionally VPN protected)
  - Server → Server (mirror / offsite replication)

---

## 🧠 Design Philosophy

hardened-borg-server follows a strict design philosophy:

- minimize attack surface
- avoid feature creep
- enforce security server-side, not client-side
- keep behavior deterministic and auditable
- shift complexity to the host system, not the application layer

---

## 🛠 Deployment Example

```bash
podman run \
  --name=hardened-borg-server \
  --rm \
  --publish=2222:22 \
  --volume=$HOME/containers/borg-server/config:/config:Z \
  --volume=$HOME/containers/borg-server/repo:/repo:Z \
  --volume=$HOME/containers/borg-server/log:/log:Z \
  ghcr.io/raykhoefemann/hardened-borg-server:0.1
