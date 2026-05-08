#!/bin/bash

# Senior PostgreSQL Initialization Script
# This script is designed to be run by the official Postgres Docker image
# It creates multiple databases and enables pgvector automatically.

set -e
set -u

# Use ${VAR:-} to avoid "unbound variable" errors when running outside of Docker
MULTIPLE_DBS="${POSTGRES_MULTIPLE_DATABASES:-}"
PG_USER="${POSTGRES_USER:-postgres}"

function create_user_and_database() {
    local database=$1
    echo "  Creating database '$database'..."
    psql -v ON_ERROR_STOP=1 --username "$PG_USER" <<-EOSQL
        CREATE DATABASE "$database";
EOSQL
    echo "  Enabling pgvector in '$database'..."
    psql -v ON_ERROR_STOP=1 --username "$PG_USER" --dbname "$database" <<-EOSQL
        CREATE EXTENSION IF NOT EXISTS vector;
EOSQL
}

if [ -n "$MULTIPLE_DBS" ]; then
    echo "Multiple database creation requested: $MULTIPLE_DBS"
    for db in $(echo "$MULTIPLE_DBS" | tr ',' ' '); do
        # Check if database exists (graceful check)
        # Note: This will only work if Postgres is already running
        DB_EXISTS=$(psql -tAc "SELECT 1 FROM pg_database WHERE datname='$db'" --username "$PG_USER" || echo "0")
        if [ "$DB_EXISTS" = "1" ]; then
            echo "  Database '$db' already exists. Ensuring pgvector is enabled..."
            psql -v ON_ERROR_STOP=1 --username "$PG_USER" --dbname "$db" <<-EOSQL
                CREATE EXTENSION IF NOT EXISTS vector;
EOSQL
        else
            create_user_and_database "$db"
        fi
    done
    echo "Initialization complete."
else
    echo "No additional databases requested (POSTGRES_MULTIPLE_DATABASES is empty)."
fi
