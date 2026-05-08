# Production Deployment: Hardened Monitoring & Database Stack

This guide details the deployment of the "Senior Engineer" monitoring stack, optimized for a **1GB VPS**. The architecture is 100% hardened using immutable containers and least-privilege principles.

## 🏛️ Architecture Overview

### Security Layer
- **docker-socket-proxy**: A secure gatekeeper for the Docker API. It prevents application containers from having direct access to the host's Docker socket.

### Database Layer
- **PostgreSQL (pgvector)**: Hardened with `SCRAM-SHA-256` and multi-DB auto-initialization.
- **Redis**: Hardened with password protection and disabled dangerous commands (`FLUSHALL`).

### Observability Layer
- **VictoriaMetrics / VictoriaLogs**: High-performance time-series and log storage.
- **Vector**: Data pipeline configured with **disk buffering** to prevent memory spikes on your 1GB VPS.
- **Grafana**: Automated visualization with secure provisioning.

## 🚀 Deployment Steps

### 1. Environment Preparation
Copy the template and configure your secrets:
```bash
cp .env.example .env
nano .env
```

### 2. Database Initialization (Automation)
The stack uses a custom initialization script (`./init-db/01-init.sh`) to eliminate manual setup.
- **Variable**: `POSTGRES_MULTIPLE_DATABASES`
- **Behavior**:
  - On first start, the script iterates through the comma-separated list.
  - It creates each database if it does not already exist.
  - It executes `CREATE EXTENSION IF NOT EXISTS vector;` in every database.
- **Scaling**: To add a new database later, simply add it to the list in `.env` and restart the stack with `docker-compose up -d`.

### 3. Launch the Stack
```bash
docker-compose up -d
```
The stack will automatically:
1. Initialize the `postly` and `learnest` databases.
2. Enable `pgvector` in each.
3. Configure internal routing for all logs/metrics.

### 3. Verification
```bash
# Check container health (Wait for 'healthy' status)
docker ps

# Monitor resource limits
docker stats
```

## 🛡️ Security Hardening Details

### Immutable Containers
All containers run with `read_only: true`. If you need to perform maintenance inside a container:
- Use `docker exec` for approved tools.
- Do NOT attempt to install packages or modify files inside the running container (they will fail).

### Zero-Trust Networking
Only the following ports are bound, and only to `127.0.0.1`:
- **Grafana**: `3000`
- **Postgres**: `5433`
- **Redis**: `6380`

### CI/CD Pipeline
Every change to this repository is validated via **GitHub Actions**:
- **Linting**: ShellCheck for init scripts, yamllint for configs.
- **Validation**: `docker-compose config` check.

## 💾 Backups
Use the provided `backup.sh` script to create daily snapshots of your relational data.
```bash
./backup.sh
```
Snapshots are stored in `./backups` and old backups (>7 days) are automatically pruned.

## 🛠️ Troubleshooting

- **"Read-only file system" error**: This is intentional. Use volumes for persistent data.
- **Postgres Health Check Fails**: Ensure your `.env` has the correct `POSTGRES_USER` and `POSTGRES_PASSWORD`.
- **Vector not seeing logs**: Check if `docker-socket-proxy` is running and healthy.
- **OOM Kill**: If the OS kills a container, verify that your total `memory: limits` in `docker-compose.yml` do not exceed 850MB.
