# Minecraft Bedrock Dedicated Server (Docker Hub Controller)

A lightweight, local Minecraft Bedrock Dedicated Server running on an Ubuntu base container. Built specifically for local LAN deployment with persistent world storage, automated runtime choices, and explicit control setups.

## 📂 Project Structure

* `config/` - Place your custom configuration files (`server.properties`, `allowlist.json`, `permissions.json`) and your assets (`resource_packs/`) here.
* `data/` - Persisted runtime execution directory containing engine dynamic maps, state tracking, and your live worlds.
* `source-minecraft-zip/` - Place the raw bedrock server engine `.zip` binary download file here.
* `entrypoint.sh` - Core bootstrap selector reading configuration switches to fork execution models.
* `interactive-server.sh` - Worker layer giving the engine immediate raw TTY terminal context.
* `run-server.sh` - Background worker daemon utilizing custom POSIX Named Pipe abstractions to preserve graceful shutdowns.
* `console.sh` - Connection mapping utility securely bridging your local shell to the container environment.
* `backup.sh` - Safe world serialization script communicating directly with internal file descriptor targets.

## ⚙️ Architecture & Execution Modes

This controller completely untangles interactive management from background daemon stabilization by allowing you to choose a dedicated execution engine via the `SERVER_MODE` environment variable inside your `docker-compose.yml`.

### 1. Service Mode (`SERVER_MODE=service`)

* **Purpose:** Production deployments, long running instances, and automated server infrastructure.
* **Pros:** Complete safety hooks. Catching host reboots, system shutdowns, and `docker compose down` will cleanly trigger an event hook, executing the `/stop` command internally and protecting data chunks from corruption (`exit code 0`).
* **Cons:** Native interactive TTY typing stream via `docker attach` is restricted.

### 2. Interactive Mode (`SERVER_MODE=interactive`)

* **Purpose:** Manual server maintenance, operational administrative updates (`/op`, `/whitelist`), and game-day tracking.
* **Pros:** Perfect command terminal access natively. Simply use `./console.sh` to type straight into the Bedrock execution matrix.
* **Cons:** Container signal tracking traps are disabled because the server binary takes direct control of PID 1. Shuts down cleanly via manual console interaction only.

## 🚀 Quick Start Guide

### 1. Infrastructure Requirements
Ensure your source and environment settings are aligned before lifting the container framework:
1. Drop your vanilla Bedrock Server `.zip` file inside `./source-minecraft-zip/`.
2. Ensure custom properties or asset sheets are organized inside `./config/`.

### 2. Launch Configuration
Set your preference (`service` or `interactive`) inside `docker-compose.yml` under the `environment` layer:

```yaml
environment:
  - SERVER_MODE=service
```

Spin up the system environment and compile structural updates in background (detached) state:

```bash
docker compose up -d --build
```

## 🎮 Accessing the Server Console

To check logs or manually manipulate server properties, utilize the custom attachment macro script:

```bash
./console.sh

```

### 🛑 Exiting the Console Safely

When you are done administering tasks inside the live terminal prompt:

* **DO NOT press `Ctrl + C`** in `interactive` mode, this will pass a kill signal straight down the root execution process, instantly crashing your active Minecraft instance.
* **DO USE `Ctrl + Q`** — This detaches your local view instantly, returning your terminal back to the host system shell while leaving the Minecraft server running perfectly in the background.

## 💾 Safe Backup Management

You can take live backups of your server world profiles without any downtime. The companion utility script handles live disk freezes safely:

```bash
./backup.sh
```

The sequence automatically signals `save hold` to flush game cache pools to persistent paths, creates a compressed archive under `./backup/`, and executes `save resume` immediately after completion to avoid blocking player chunk alterations.

## 🌐 LAN & Network Reference

* **Port Access Layer:** `19132` (UDP)
* **Firewall Scope:** Ensure your host operating system and network routing interfaces have explicit exceptions allowing inbound connection vectors across `19132/udp` for seamless LAN multiplayer discovery.