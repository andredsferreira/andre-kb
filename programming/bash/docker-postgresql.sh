#!/usr/bin/env bash
set -euo pipefail

POSTGRES_PASSWORD="${POSTGRES_PASSWORD:-changeme}"

cleanup() {
  echo
  echo "Caught interrupt, cleaning up..."
  docker rm -f postgres >/dev/null 2>&1 || true
  docker network rm postgres-net >/dev/null 2>&1 || true
  echo "Cleanup done. (Volume 'postgres-data' was kept.)"
  exit 0
}

trap cleanup SIGINT SIGTERM

docker network create postgres-net

docker volume create postgres-data

docker run -d --name postgres \
  --network postgres-net \
  -p 5432:5432 \
  -e POSTGRES_PASSWORD="$POSTGRES_PASSWORD" \
  -v postgres-data:/var/lib/postgresql/data \
  postgres:16

echo "Postgres is starting. It may take a few seconds to become available."
echo "Connect with:"
echo "  psql -h localhost -p 5432 -U postgres"
echo "or:"
echo "  docker exec -it postgres psql -U postgres"
echo
echo "Press Ctrl+C to stop and clean up."

sleep infinity