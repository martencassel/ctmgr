
# `ctmgr` (Container Manager)

**ctmgr** is a command-line tool for managing pools of Linux containers that behave like virtual machines. It integrates with **systemd-nspawn** (or similar systemd container tooling) and bridges into **Docker Compose** for provisioning and orchestration.

---

## Core Challenges & Solutions

### 1. Provision Docker Compose with systemd settings
- **Problem**: Docker Compose doesn’t natively understand systemd containers.
- **Solution**: `ctmgr` generates Compose YAML fragments that wrap systemd-nspawn containers with the right configuration:
  - Mounts `/sys/fs/cgroup` properly
  - Sets `cap_add` and `security_opt` for systemd compatibility
  - Configures networking (bridge or macvlan) so containers behave like VMs
  - Adds healthchecks for systemd services

Example generated snippet:

```yaml
version: "3.9"
services:
  debian_vm1:
    image: debian-systemd:latest
    container_name: debian_vm1
    privileged: true
    volumes:
      - /sys/fs/cgroup:/sys/fs/cgroup:rw
    command: ["/sbin/init"]
    networks:
      - vmnet
networks:
  vmnet:
    driver: bridge
```

---

### 2. Base images for various distros
- **Problem**: Standard Docker images don’t ship with systemd enabled/configured.
- **Solution**: `ctmgr` maintains curated base images:
  - `debian-systemd:latest`
  - `ubuntu-systemd:latest`
  - `centos-systemd:latest`
  - `fedora-systemd:latest`
- Each image:
  - Boots with `/sbin/init`
  - Has minimal systemd services enabled
  - Configured for clean shutdown/reboot inside Docker
  - Includes SSH for VM-like access (optional)

---

## Features

✨ **VM-like Container Pools**
- Create pools of containers that act like Linux VMs
- Allocate containers from a pool automatically
- Release containers when no longer needed

🛡️ **Safe Integration**
- Managed block in Docker Compose files
- Never overwrites user-defined services
- Clean add/remove operations

📊 **State Tracking**
- Persistent state in `~/.ctmgr_state`
- Tracks which containers are allocated
- Export container info for Compose or other tools

🎨 **Beautiful CLI**
- Colorful, organized output
- Progress indicators and status messages

---

## Usage

```bash
# Show help
ctmgr

# Allocate a new VM-like container from Ubuntu pool
ctmgr alloc --pool ubuntu --name vm1

# List all managed containers
ctmgr list

# Release a container
ctmgr release vm1

# Export Compose fragment
ctmgr render-compose --pool ubuntu --count 3 > docker-compose.override.yml
```

---

## Example Workflow

```bash
# Allocate 3 Ubuntu VM-like containers
$ ctmgr alloc --pool ubuntu --count 3
✓ Allocated vm1 (ubuntu-systemd)
✓ Allocated vm2 (ubuntu-systemd)
✓ Allocated vm3 (ubuntu-systemd)

# Export Compose config
$ ctmgr render-compose --pool ubuntu --count 3 > docker-compose.override.yml

# Bring them up
$ docker-compose up -d
```

---

## Use Cases

- **Testing environments**: Spin up multiple distros as VM-like containers
- **CI/CD pipelines**: Run systemd-based services inside containers
- **Service deployment**: Treat containers as lightweight VMs
- **Development**: Experiment with multiple Linux distros without heavy VM overhead

---

👉 This tool would essentially bridge **systemd-nspawn semantics** with **Docker Compose orchestration**, giving you VM-like behavior but container-level efficiency.
# ctmgr
