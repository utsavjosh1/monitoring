# Monitoring & Database Stack

This repository contains the `docker-compose` setup for the unified **Monitoring** and **Database** stack. This stack has been highly optimized to run under **1GB** of memory, ensuring minimal footprint while still supporting advanced features for projects like **Postly** and **Learnest**.

## Included Services

### Databases (For Application Use)
| Service | Image | Exposed Port | Memory Limit | Credentials (Default) |
|---------|-------|--------------|--------------|-----------------------|
| **PostgreSQL** | `pgvector/pgvector:pg17` | `5432` | `256M` | `postgres` / `postgres` (DB: `postgres`) |
| **Redis** | `redis:7-alpine` | `6379` | `64M` | No password |

### Monitoring (Internal / Observability)
| Service | Image | Exposed Port | Memory Limit | Purpose |
|---------|-------|--------------|--------------|---------|
| **Grafana** | `grafana-oss:11.0.0` | `3000` | `128M` | Metrics and logs visualization (u: admin, p: admin) |
| **VictoriaMetrics** | `victoria-metrics:v1.101.0` | Internal | `192M` | Time-series metrics storage |
| **VictoriaLogs** | `victoria-logs:v0.12.0` | Internal | `192M` | Log storage |
| **Vector** | `vector:0.38.0-alpine` | Internal | `128M` | Log and metric routing pipeline |

> **Total Configured Memory Limit**: `960MB` (Safely fits under the 1GB hard limit).

## Prerequisites
- Docker
- Docker Compose

## Usage

### Start the Stack
```bash
docker-compose up -d
```

### Stop the Stack
```bash
docker-compose down
```

### View Logs
```bash
docker-compose logs -f
```

### Monitoring URLS
```bash
http://localhost:3000/grafana/ (u: admin, p: admin)
http://localhost:9428/logs/
http://localhost:8428/metrics/
```

## Connecting from Applications (Postly / Learnest)
When running your applications locally, you can connect directly to the exposed ports on `localhost` (or the VPS host IP):
- **Postgres URL**: `postgres://postgres:postgres@localhost:5432/postgres`
- **Redis URL**: `redis://localhost:6379`
