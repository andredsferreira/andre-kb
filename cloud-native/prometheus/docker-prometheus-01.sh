#!/usr/bin/env bash
set -euo pipefail

cleanup() {
  echo
  echo "Caught interrupt, cleaning up..."
  docker rm -f prometheus node-exporter >/dev/null 2>&1 || true
  docker network rm monitoring >/dev/null 2>&1 || true
  echo "Cleanup done."
  exit 0
}

trap cleanup SIGINT SIGTERM

docker network create monitoring

docker run -d --name node-exporter \
  --network monitoring \
  -p 9100:9100 \
  prom/node-exporter

docker run -d --name prometheus \
  --network monitoring \
  --mount type=bind,source=/home/andre/andre-kb/cloud-native/prometheus/prometheus-01.yml,target=/etc/prometheus/prometheus.yml \
  -p 9090:9090 \
  prom/prometheus:latest \
  --config.file=/etc/prometheus/prometheus.yml \
  --web.enable-lifecycle

echo "Prometheus and node-exporter are running. Press Ctrl+C to stop and clean up."

sleep infinity