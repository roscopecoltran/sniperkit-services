#!/bin/bash
set -e

echo "# Demo config:" >> /var/lib/postgresql/data/postgresql.conf
echo "shared_preload_libraries = 'pg_stat_statements'" >> /var/lib/postgresql/data/postgresql.conf

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
  CREATE USER root SUPERUSER;

  CREATE USER demo SUPERUSER;

  CREATE DATABASE "demo-dev";
  GRANT ALL PRIVILEGES ON DATABASE "demo-dev" TO demo;

  CREATE DATABASE "demo-test";
  GRANT ALL PRIVILEGES ON DATABASE "demo-test" TO demo;
EOSQL
