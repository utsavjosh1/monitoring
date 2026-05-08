# Senior Monitoring & Database Stack (100% Hardened)

This repository contains the `docker-compose` setup for a unified **Monitoring** and **Database** stack, optimized for a **1GB VPS**. This "Senior" version is **100% hardened** (Fort Knox grade) and fully automated for production use.

## Key Features
- **100% Security Hardening**: Zero-capability containers, Read-only filesystems, and Docker Socket Proxy.
- **Dynamic Initialization**: Automatic database creation (`postly`, `learnest`, etc.) and `pgvector` setup.
- **Strict Memory Capping**: Total resource footprint limited to **~750MB** to ensure OS stability.
- **CI/CD Integrated**: Automated validation of configurations and shell script linting.
- **Production Auth**: Enforced `SCRAM-SHA-256` for Postgres and Redis password authentication.

## Included Services

### Databases (Hardened)
| Service | Image | Exposed Port | Memory Limit | Auth |
|---------|-------|--------------|--------------|------|
| **PostgreSQL** | `pgvector/pgvector:pg17` | `5433` (Local) | `192M` | SCRAM-SHA-256 |
| **Redis** | `redis:7-alpine` | `6380` (Local) | `48M` | Password Protected |

### Monitoring & Security
| Service | Image | Exposed Port | Memory Limit | Purpose |
|---------|-------|--------------|--------------|---------|
| **Grafana** | `grafana-oss:11.0.0` | `3000` (Local) | `96M` | Visualization & Alerting |
| **VictoriaMetrics** | `victoria-metrics:v1.101.0` | Internal | `160M` | Time-series storage |
| **VictoriaLogs** | `victoria-logs:v0.12.0` | Internal | `160M` | High-perf log storage |
| **Vector** | `vector:0.38.0-alpine` | Internal | `96M` | Logic pipeline (with disk buffering) |
| **Socket Proxy** | `docker-socket-proxy` | Internal | `32M` | Secure gatekeeper for Docker API |

## Usage

### 1. Setup Environment
Copy the example environment file and set your secure passwords:
```bash
cp .env.example .env
# Edit .env and change default passwords!
```

### 2. Start the Stack
```bash
docker-compose up -d
```

### 3. Database Initialization & Management
This stack automatically handles database creation on the first run.
- **Auto-Init**: List databases in `.env` under `POSTGRES_MULTIPLE_DATABASES`.
- **Add DB Live**: To add a database while the stack is running, use the helper script:
  ```bash
  chmod +x add_db.sh
  chmod +x ./scripts/add_db.sh
  ./scripts/add_db.sh new_database_name
  ```

### 4. Automated Backups
Run the included backup script to dump all databases:
```bash
chmod +x ./scripts/backup.sh
./scripts/backup.sh
```

## Security Overview
- **Immutable Infrastructure**: All containers run with `read_only: true`.
- **Least Privilege**: `cap_drop: [ALL]` is enforced.
- **Zero-Trust Networking**: All metrics/logs are routed via an internal Docker bridge network.
- **Socket Isolation**: No application container has direct access to `/var/run/docker.sock`.

## Maintenance
- **Check Health**: `docker ps` (Wait for `healthy` status).
- **Check Resource Usage**: `docker stats`.
- **Logs**: `docker-compose logs -f <service_name>`.
