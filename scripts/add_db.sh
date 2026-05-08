#!/bin/bash

# Senior Helper: Add Database & Enable Extensions
# Usage: ./scripts/add_db.sh <database_name>

# Get the root directory of the project
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

# Load environment variables from root
if [ -f "$ROOT_DIR/.env" ]; then
    export $(grep -v '^#' "$ROOT_DIR/.env" | xargs)
fi

DB_NAME=$1
PG_USER=${POSTGRES_USER:-postgres}

if [ -z "$DB_NAME" ]; then
    echo "❌ Error: No database name provided."
    echo "Usage: ./scripts/add_db.sh <database_name>"
    exit 1
fi

echo "🚀 Adding database '$DB_NAME' to running container..."

# 1. Create the database
docker exec -it postgres psql -U "$PG_USER" -c "CREATE DATABASE \"$DB_NAME\";"

# 2. Enable pgvector extension
echo "🧬 Enabling pgvector extension in '$DB_NAME'..."
docker exec -it postgres psql -U "$PG_USER" -d "$DB_NAME" -c "CREATE EXTENSION IF NOT EXISTS vector;"

echo "✅ Database '$DB_NAME' is ready for use!"
echo "💡 Reminder: Add '$DB_NAME' to POSTGRES_MULTIPLE_DATABASES in your .env for future persistence."
