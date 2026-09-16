#!/usr/bin/env bash
set -euo pipefail

cleanup() {
  echo
  echo "Caught interrupt, cleaning up..."
  docker rm -f tomcat >/dev/null 2>&1 || true
  docker network rm tomcat-net >/dev/null 2>&1 || true
  echo "Cleanup done."
  exit 0
}

trap cleanup SIGINT SIGTERM

docker network create tomcat-net

docker volume create tomcat-data

docker run -d --name tomcat \
  --network tomcat-net \
  -p 8080:8080 \
  -v tomcat-data:/usr/local/tomcat/webapps \
  tomcat:latest

echo "Tomcat is starting. It may take a minute to become available."
echo "Open http://localhost:8080 in your browser."
echo
echo "Press Ctrl+C to stop and clean up."

sleep infinity