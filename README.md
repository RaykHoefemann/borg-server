# hardened-borg-server

**Security-hardened BorgBackup server for controlled multi-client environments**

hardened-borg-server is a minimal, security-focused server wrapper around BorgBackup designed to receive backups from multiple clients in a strictly controlled environment.

It intentionally avoids feature complexity such as web interfaces, orchestration systems, or multi-purpose APIs in order to maintain a small, auditable, and predictable security surface.

---

# 🔐 Security Model Overview

hardened-borg-server is designed as a **two-layer security system**:

## 1. Application Security Layer (this project)

This project enforces security at the application level:

- SSH-based access control for Borg operations
- Repository isolation per client
- Forced command execution (no interactive shell access)
- Append-only enforcement at application layer
- Client isolation via configuration mapping
- Minimal attack surface (SSH-only interface)

## 2. Host Security Layer (OPERATOR RESPONSIBILITY)

The host system is a **mandatory security boundary** and is explicitly outside the scope of this project.

Secure operation requires a hardened host environment provided and maintained by the operator.

---

## 🧱 Host Security Layer (CRITICAL SECURITY BOUNDARY)

### ⚠️ This project does NOT provide host-level security.

The application alone is NOT sufficient to ensure secure operation.

The host layer must provide isolation and containment guarantees that cannot be enforced by the application.

---

## 🎯 Why this layer is required

This layer protects against **system-level compromise scenarios** that cannot be mitigated at application level.

Without it, a vulnerability in the backup service could lead to:

- full access to the host filesystem
- access to other clients’ backup data
- privilege escalation from container to host
- persistence beyond application scope

---

## 🧨 Threat Scenarios mitigated by the Host Layer

### 1. Container escape / runtime breakout
If an attacker exploits a vulnerability in Borg or the runtime:
- Rootless containers and SELinux confinement limit host access
- Compromise is contained within restricted namespaces

### 2. Full compromise of the borg-server process
If the application is fully compromised:
- SELinux restricts filesystem and process access
- Host-level isolation prevents unrestricted system access

### 3. Cross-client isolation failure
If application isolation fails:
- Host-level separation provides an additional enforcement boundary

### 4. Persistence attacks
If attacker gains execution inside container:
- Immutable host systems reduce persistence opportunities
- System modifications require explicit host-level changes

---

## 🧱 Security Effect of the Host Layer

When implemented correctly (e.g. Fedora CoreOS + SELinux + rootless containers), this layer provides:

- containment of compromised processes
- reduced filesystem and kernel access
- significantly reduced attack surface of the base system
- prevention of trivial privilege escalation paths
- reduced blast radius of application compromise

---

## 🧱 Required Host Stack (Operator Responsibility)

A secure deployment typically includes:

- Fedora CoreOS (immutable operating system)
- SELinux in enforcing mode (mandatory access control)
- Rootless container runtime (e.g. Podman)
- Proper firewall and network segmentation
- Secure storage configuration

---

## 🔐 Core Principle

Security is achieved only when BOTH layers are present:

> Application enforcement + hardened host isolation = secure system

Neither layer is sufficient on its own.

See `BEST_PRACTICES.md` for the required operational baseline.

---

# 🔒 Security Guarantees (when correctly deployed)

When deployed according to `BEST_PRACTICES.md` on a properly hardened host system, the application layer provides:

- strict repository isolation per client
- no shell or interactive access for clients
- server-side enforced access control via forced commands
- append-only backup semantics at application level
- no cross-client access via configuration isolation
- minimal external attack surface (SSH only)

---

# ⚠️ Deployment Requirement

hardened-borg-server is NOT a standalone secure system.

It MUST be deployed on a properly hardened host system as described above.

Failure to implement the host layer removes a critical security boundary.

---

# ✨ Features

- 🔒 Security-focused design (minimal attack surface)
- 👥 Multi-client backup support
- 🗂️ Strict repository isolation per client
- 🔁 Mirror/offsite backup ingestion support
- 📦 Per-client quota enforcement (advisory, configuration-driven)
- ℹ️ Read-only client info channel (server contact + quota info via SSH)
- ⚙️ Fully config-driven behavior
- 🧪 Safe testing environment for backup validation
- 📝 Centralized logging in `/log`
- 🚫 No orchestration layer (deterministic execution only)

---

# 🔐 Application Security Model

## Access Control

- SSH key-based authentication only
- Password authentication disabled
- Root login disabled
- Dedicated SSH key per client
- Forced command execution prevents shell access
- Clients restricted to assigned repository paths

---

## SSH Hardening

- Modern cryptographic algorithms only
- Legacy algorithms disabled
- No TTY, X11, forwarding, or tunneling
- Connection limits enforced
- Persistent SSH host keys for stable identity

---

## Repository Isolation

- Each client mapped to a dedicated repository path
- Access enforced via configuration + forced commands
- No cross-repository filesystem access via application layer

---

## Append-Only Semantics

- Backup archives can only be appended
- Deletion/modification of existing archives is prevented via application enforcement
- Historical backups remain immutable via Borg interface

---

## Network Exposure

- No web interface
- No HTTP API
- SSH is the only external interface

---

# 🧱 Architecture Overview

- Base image: `debian:stable-slim` with BorgBackup installed
- Containerized runtime (Podman or Docker recommended)
- Rootless execution strongly recommended
- Systemd-compatible deployment supported

### Storage Model

- Separate volume for repositories
- Separate volume for logs
- Separate volume for configuration

---

## Backup Flows

- Client → Server (SSH / optionally VPN)
- Server → Server (mirror/offsite replication)

---

# 🛠 Deployment Example

```bash
podman run \
  --name=hardened-borg-server \
  --rm \
  --publish=2222:22 \
  --volume=$HOME/containers/borg-server/config:/config:Z \
  --volume=$HOME/containers/borg-server/repo:/repo:Z \
  --volume=$HOME/containers/borg-server/log:/log:Z \
  ghcr.io/raykhoefemann/hardened-borg-server:0.1
```

---

# ⚙️ Configuration

All client access is config-driven. Nothing is provisioned automatically beyond what is explicitly defined in `/config`.

## clients.conf

- **File:** `config/clients.conf`
- **Format:** `<client>:<group>:<repo>:<quota>`
- **Groups:**
  - `OWN` – internal clients from your own network
  - `MIRROR` – external clients (e.g. friends, offsite partners)
- **Quota:** mandatory, format `<number>G` (e.g. `10G`, `50G`). There is no `unlimited` value — every client must have an explicit quota.

**Example:**

```
user1-os1-pc1:OWN:/repo/OWN/user1-os1-pc1:50G
user2-os1-pc1:OWN:/repo/OWN/user2-os1-pc1:50G
user-pc2:OWN:/repo/OWN/user-pc2:20G
friend1:MIRROR:/repo/MIRROR/friend1:200G
```

> Quota is currently advisory/informational (surfaced via the `info` command, see below). It is read and validated on the server side, but is not yet enforced as a hard filesystem limit.

## SSH Keys

- Each client has a dedicated public key stored in `config/keys/<client>.pub`
- The file name must match the client name exactly

**Example structure:**

```
config/keys/
├── user1-os1-pc1.pub
├── user2-os1-pc1.pub
├── user-pc2.pub
└── friend1.pub
```

## server_info.conf

- **File:** `config/server_info.conf`
- **Format:** `key=value`
- **Required keys:** `name`, `location`, `contact`

**Example:**

```
name=backup01.example.com
location=Frankfurt, DE
contact=admin@example.com
```

This file describes the server itself (not any individual client) and is shown to every client via the `info` command below. All three keys are mandatory — the container will refuse to start `authorized_keys` generation if any are missing.

## Visual Overview

```
clients.conf + keys/ + server_info.conf ---> hardened-borg-server ---> Repositories (/repo/...)
```

---

# ℹ️ Client Info Channel

Each client can query basic server and account information over the same SSH connection used for backups — no additional service, port, or protocol is involved.

```bash
ssh -p 2222 borg@<server-host> info
```

This returns a small, read-only text file (`info.txt`, stored inside the client's own repository path) containing:

```
[server]
name: backup01.example.com
location: Frankfurt, DE
contact: admin@example.com

[client]
user: user1-os1-pc1
quota: 50G
```

- `info.txt` is generated and updated automatically whenever `authorized_keys` is rebuilt (i.e. on every container start), based on `clients.conf` and `server_info.conf`.
- It is read-only from the client's perspective — clients cannot modify it.
- No interactive shell, TTY, or any command other than `info` and the normal Borg protocol is accepted; any other command is rejected.

---

# 🧰 Client Management Scripts

Helper scripts under `scripts/` simplify adding and managing clients on the host side. They operate on the host-side configuration directory (`config/clients.conf`, `config/keys/`) before the container is started or restarted.

## 00-ssh-create-user.sh

Creates a new client entry and an empty key placeholder.

```bash
./scripts/00-ssh-create-user.sh <username> <group> <quota>
```

- `<group>`: `OWN` or `MIRROR`
- `<quota>`: mandatory, format `<number>G` (e.g. `50G`)

**Example:**

```bash
./scripts/00-ssh-create-user.sh user1-os1-pc1 OWN 50G
```

## 01-ssh-set-user-key.sh

Sets (or overwrites, with confirmation) the public SSH key for an existing client. Accepts either a path to a key file or the key string directly.

```bash
./scripts/01-ssh-set-user-key.sh <username> <keyfile|keystring>
```

**Examples:**

```bash
./scripts/01-ssh-set-user-key.sh user1-os1-pc1 ~/.ssh/id_ed25519.pub
./scripts/01-ssh-set-user-key.sh user1-os1-pc1 "ssh-ed25519 AAAA… user1-os1-pc1"
```

## 02-ssh-set-user-quota.sh

Changes the quota of an existing client without affecting its group or repository path.

```bash
./scripts/02-ssh-set-user-quota.sh <username> <quota>
```

**Example:**

```bash
./scripts/02-ssh-set-user-quota.sh user1-os1-pc1 100G
```

> After any change made via these scripts, restart the container so `build_authorized_keys.sh` regenerates `authorized_keys` and `info.txt` for all clients.

---

## 💡 Security & Best Practices

hardened-borg-server enforces strict server-side security measures (see Security Model above).
However, secure operation also depends on proper configuration and operational practices by the administrator.

⚠️ **Important:** Please review the [Best Practices Guide](./BEST_PRACTICES.md) for recommendations on secure usage, including:

- Encrypting backups before mirroring
- Using tunneled connections for remote replication
- Exposing only the necessary SSH port
- Regular monitoring and verification of backups
