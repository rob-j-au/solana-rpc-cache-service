#!/bin/sh
set -e

MIGRATIONS_DIR="/postgres"

# Create migrations tracking table if not exists
PGPASSWORD=$POSTGRES_PASSWORD psql -h postgres -U $POSTGRES_USER -d $POSTGRES_DB -c "
  CREATE TABLE IF NOT EXISTS _sqlx_migrations (
    version BIGINT PRIMARY KEY,
    description TEXT NOT NULL,
    installed_on TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    success BOOLEAN NOT NULL,
    checksum TEXT NOT NULL,
    execution_time BIGINT NOT NULL
  );
"

# Run each migration if not already applied
for file in $MIGRATIONS_DIR/*.sql; do
  filename=$(basename "$file")
  version=$(echo "$filename" | cut -d'_' -f1)
  description=$(echo "$filename" | sed 's/^[0-9]*_//' | sed 's/.sql$//')
  checksum=$(md5sum "$file" | cut -d' ' -f1)
  
  # Check if migration already applied
  applied=$(PGPASSWORD=$POSTGRES_PASSWORD psql -h postgres -U $POSTGRES_USER -d $POSTGRES_DB -tAc "
    SELECT 1 FROM _sqlx_migrations WHERE version = $version AND success = true;
  ")
  
  if [ -z "$applied" ]; then
    echo "Applying migration: $filename"
    start_time=$(date +%s%3N)
    if PGPASSWORD=$POSTGRES_PASSWORD psql -h postgres -U $POSTGRES_USER -d $POSTGRES_DB -f "$file"; then
      end_time=$(date +%s%3N)
      execution_time=$((end_time - start_time))
      PGPASSWORD=$POSTGRES_PASSWORD psql -h postgres -U $POSTGRES_USER -d $POSTGRES_DB -c "
        INSERT INTO _sqlx_migrations (version, description, success, checksum, execution_time)
        VALUES ($version, '$description', true, '$checksum', $execution_time)
        ON CONFLICT (version) DO UPDATE SET success = true, installed_on = NOW();
      "
      echo "Migration $filename applied successfully"
    else
      echo "Migration $filename failed"
      exit 1
    fi
  else
    echo "Migration $filename already applied, skipping"
  fi
done

echo "All migrations completed"
