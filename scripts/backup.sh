#!/bin/bash

# Senior PostgreSQL Backup Script
# Usage: ./scripts/backup.sh

# Get the root directory of the project
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

# Load environment variables from root
if [ -f "$ROOT_DIR/.env" ]; then
    export $(grep -v '^#' "$ROOT_DIR/.env" | xargs)
fi

BACKUP_DIR="$ROOT_DIR/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
mkdir -p "$BACKUP_DIR"

echo "Starting backup of all databases..."

# List of databases from .env
IFS=',' read -ra ADDR <<< "${POSTGRES_MULTIPLE_DATABASES:-}"
# Add default postgres DB
ADDR+=("postgres")

for db in "${ADDR[@]}"; do
    if [ -z "$db" ]; then continue; fi
    echo "  Backing up database: $db"
    docker exec postgres pg_dump -U "${POSTGRES_USER:-postgres}" "$db" > "$BACKUP_DIR/${db}_$TIMESTAMP.sql"
    if [ $? -eq 0 ]; then
        echo "  Backup successful: ${db}_$TIMESTAMP.sql"
    else
        echo "  Error backing up database: $db"
    fi
done

# Optional: Remove backups older than 7 days
find "$BACKUP_DIR" -name "*.sql" -type f -mtime +7 -delete

echo "Backup process completed."
