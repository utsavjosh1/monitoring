# Deployment Guide: Global Monitoring & Database Stack

This repository contains the configuration and deployment setup for a centralized, highly-optimized **Monitoring and Database** stack designed to serve multiple projects (like Postly and Learnest) from a single VPS or local environment. The entire stack is configured to run under a strict **1GB memory limit**.

## Architecture Overview

### Database Layer
- **PostgreSQL (`pgvector`)**: Stores relational application data and vector embeddings.
- **Redis**: In-memory data store for caching and queues.

### Observability Layer
- **VictoriaMetrics**: Collects and stores time-series metrics. Extremely efficient alternative to Prometheus.
- **VictoriaLogs**: High-performance log aggregation system. Efficient alternative to Loki/Elasticsearch.
- **Vector**: Universal log and metric router/shipper. Efficient alternative to Promtail/Logstash.
- **Grafana**: Unified dashboard for visualizing metrics and logs.

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)

## Local Deployment

To run the stack locally for development or testing:

1. **Launch the stack**:
   ```bash
   docker-compose up -d
   ```

2. **Access the Services**:
   - **Grafana**: `http://localhost:3000` (User: `admin`, Password: `admin`)
   - **PostgreSQL**: `localhost:5432` (User: `postgres`, Password: `postgres`)
   - **Redis**: `localhost:6379` (No password)

3. **Initialize Application Databases**:
   By default, PostgreSQL only contains the `postgres` database. Create your app databases manually the first time:
   ```bash
   docker exec -it postgres psql -U postgres -c "CREATE DATABASE postly;"
   docker exec -it postgres psql -U postgres -c "CREATE DATABASE learnest;"
   ```

## VPS Deployment Considerations

When deploying to a production VPS, consider the following:

### 1. Security & SSL
It is highly recommended to run this stack behind a reverse proxy like **Nginx** or **Traefik** to handle SSL (HTTPS) and basic authentication. Do not expose monitoring endpoints without authentication.

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
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

### 2. Network Security
- Ensure internal ports for `VictoriaMetrics` (8428), `VictoriaLogs` (9428), and `Vector` are **not** exposed directly to the public internet. 
- Only expose `Grafana` (3000), `PostgreSQL` (5432), and `Redis` (6379) if strictly necessary, ideally restricting access via a Firewall (UFW) to only allow traffic from trusted application IPs.
- **Crucial**: Change the default passwords for Grafana and PostgreSQL in production via environment variables.

### 3. Data Persistence
Docker volumes are used to ensure data isn't lost on restart:
- `vmdata`: VictoriaMetrics time-series data
- `vldata`: VictoriaLogs log data
- `grafana_data`: Grafana configuration and dashboards
- `pgdata`: PostgreSQL database files
- `redisdata`: Redis append-only files / snapshots

Ensure your VPS has enough disk space for long-term metric/log retention and database growth.

## Configuration Details

- `config/vector/vector.toml`: Defines which logs and metrics Vector should scrape and where to send them.
- `config/grafana/provisioning/`: Contains automated datasource and dashboard setups for Grafana.

## Troubleshooting

- **Check logs**: `docker-compose logs -f <service-name>`
- **Verify containers**: `docker ps`
- **Memory usage**: `docker stats` (Ensure total memory is under the configured 960MB limit)
- **Reset data**: `docker-compose down -v` (**Warning**: this deletes ALL stored databases, metrics, and logs)
