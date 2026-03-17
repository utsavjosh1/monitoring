# Deployment Guide: Global Monitoring Stack

This repository contains the configuration and deployment setup for a centralized monitoring stack (Prometheus, Loki, Promtail, Grafana) designed to monitor multiple projects from a single VPS or local environment.

## Architecture Overview

- **Prometheus**: Collects and stores time-series metrics from applications and infrastructure.
- **Loki**: Log aggregation system (like Prometheus, but for logs).
- **Promtail**: Log shipper that scrapes Docker container logs and sends them to Loki.
- **Grafana**: Unified dashboard for visualizing both metrics (Prometheus) and logs (Loki).

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)

## Local Deployment

To run the monitoring stack locally for development or testing:

1. **Clone the repository** (if not already done):
   ```bash
   git clone <repository-url>
   cd monitoring
   ```

2. **Launch the stack**:
   ```bash
   docker-compose up -d
   ```

3. **Access Grafana**:
   - URL: `http://localhost:3101`
   - Default User: `admin`
   - Default Password: `admin` (or as defined in `.env` if using one)

## VPS Deployment Considerations

When deploying to a production VPS, consider the following:

### 1. Security & SSL
It is highly recommended to run this stack behind a reverse proxy like **Nginx** or **Traefik** to handle SSL (HTTPS) and basic authentication.

Example Nginx Config Snippet for Grafana:
```nginx
server {
    listen 80;
    server_name monitoring.yourdomain.com;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl;
    server_name monitoring.yourdomain.com;

    ssl_certificate /etc/letsencrypt/live/monitoring.yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/monitoring.yourdomain.com/privkey.pem;

    location / {
        proxy_pass http://localhost:3101;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

### 2. Network Security
- Ensure ports `3101` (Grafana), `9090` (Prometheus), and `3100` (Loki) are not exposed directly to the public internet unless documented and secured.
- Use a Firewall (UFW) to only allow traffic from trusted sources or via the reverse proxy.

### 3. Data Persistence
Volumes are used for data persistence:
- `prom_data`: Prometheus metrics
- `loki_data`: Loki logs
- `grafana_data`: Grafana configuration and dashboards

Ensure your VPS has enough disk space for long-term data retention (configured to 30 days by default in `docker-compose.yml`).

## Configuration Details

- `config/prometheus.yml`: Define scrape jobs and targets.
- `config/loki.yml`: Storage and retention settings for logs.
- `config/promtail.yml`: Define which logs to scrape (defaults to all Docker containers).

## Troubleshooting

- **Check logs**: `docker-compose logs -f <service-name>`
- **Verify containers**: `docker ps`
- **Reset data**: `docker-compose down -v` (Warning: this deletes all stored metrics and logs)
