# Best Practices for borg-server

These are recommended practices for using borg-server securely and effectively.  
**Note:** These are guidelines for administrators; borg-server does **not enforce these practices**—they must be implemented at the operator level.

---

## 🔐 Backup Encryption

- Always **encrypt backups on the source server** before sending them to another borg-server (mirror/offsite replication).  
  This ensures that mirrored backups remain private even if the target server is compromised.

---

## 🔗 Secure Transport

- Use **tunneled connections**, such as WireGuard or SSH tunnels, when replicating backups over untrusted networks.  
- Only expose the necessary **SSH port**; avoid exposing additional services.

---

## 📝 Monitoring & Verification

- Regularly monitor logs stored in `/log` to ensure backups are being received correctly.  
- Periodically verify backup integrity using `borg check` or equivalent mechanisms.  
- Test restoration procedures to ensure data can be recovered when needed.

---

## 🧪 Testing Before Production

- Use borg-server’s **safe testing environment** to validate backup strategies before deploying to production.  
- Simulate restore scenarios to confirm that backup and mirror workflows function as intended.

---

## ⚙️ Operational Hygiene

- Apply updates to both borg-server and the base system (`debian:stable-slim`) regularly to benefit from security patches.  
- Maintain clear separation of repositories, logs, and configuration volumes to prevent accidental data leaks or overwrites.

---

## 📌 Summary

Following these practices helps ensure:

- Data confidentiality (via encryption)  
- Data integrity (via append-only enforcement and verification)  
- Minimal exposure to external threats (via secure transport and minimal open ports)  
- Predictable and reliable backup operations
