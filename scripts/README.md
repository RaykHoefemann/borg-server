# Backup Server Management Scripts

This collection of scripts helps you manage your backup server at host site.
The scripts are organized by functionality for easier usage and maintenance.

---

## 🔐 SSH User Management (generating config/clients.conf)

Scripts for managing SSH access:

* `00-ssh-create_user.sh`
  Creates a new user

* `01-ssh-set-user-key.sh`
  Sets or updates a user's SSH key

* `02-ssh-delete-user.sh`
  Deletes an existing user

* `09-ssh-list-user.sh`
  Lists all existing users

---

## ⚙️ Service Installation

* `50-service-install.sh`
  Installs required services on the server

---

## 📦 Container Management

Scripts for managing containers:

* `90-container-start.sh`
  Starts containers

* `91-container-stop.sh`
  Stops containers

* `92-container-restart.sh`
  Restarts containers

* `99-container-status.sh`
  Displays the status of containers

---

## 📝 Notes

* This scripts are tested with Fedora CoreOS 
* It is recommended to review each script before executing it
