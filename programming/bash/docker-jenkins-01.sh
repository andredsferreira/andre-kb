#!/usr/bin/env bash
set -euo pipefail

cleanup() {
  echo
  echo "Caught interrupt, cleaning up..."
  docker rm -f jenkins >/dev/null 2>&1 || true
  docker network rm jenkins-net >/dev/null 2>&1 || true
  echo "Cleanup done."
  exit 0
}

trap cleanup SIGINT SIGTERM

docker network create jenkins-net

docker volume create jenkins-data

docker run -d --name jenkins \
  --network jenkins-net \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins-data:/var/jenkins_home \
  jenkins/jenkins:lts

echo "Jenkins is starting. It may take a minute to become available."
echo "Open http://localhost:8080 in your browser."
echo
echo "To get the initial admin password once it's ready, run:"
echo "  docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword"
echo
echo "Press Ctrl+C to stop and clean up."

sleep infinity