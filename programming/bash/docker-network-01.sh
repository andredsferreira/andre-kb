#!/usr/bin/env bash
set -euo pipefail

cleanup() {
    echo
    echo "Caught interrupt, cleaning up..."
    docker rm -f netutils sshserver webserver >/dev/null 2>&1 || true
    docker network rm lab >/dev/null 2>&1 || true
    echo "Cleanup done."
    exit 0
}

trap cleanup SIGINT SIGTERM

docker network create lab

docker run -dit --name netutils \
    --network lab \
    nicolaka/netshoot

docker run -d --name sshserver \
    --network lab \
    -p 2222:2222 \
    -e USER_NAME=labuser \
    -e USER_PASSWORD=labpass \
    -e PASSWORD_ACCESS=true \
    lscr.io/linuxserver/openssh-server

docker run -d --name webserver \
    --network lab \
    -p 8080:80 \
    httpd:latest

echo "Lab is up:"
echo "  netutils   -> docker exec -it netutils bash"
echo "  sshserver  -> ssh labuser@localhost -p 2222 (password: labpass)"
echo "  webserver  -> http://localhost:8080"
echo

echo "Container hostnames and IP addresses on 'lab' network:"
printf "%-12s %-20s %-15s\n" "CONTAINER" "HOSTNAME" "IP ADDRESS"
for c in netutils sshserver webserver; do
    hostname=$(docker inspect -f '{{.Config.Hostname}}' "$c")
    ip=$(docker inspect -f '{{.NetworkSettings.Networks.lab.IPAddress}}' "$c")
    printf "%-12s %-20s %-15s\n" "$c" "$hostname" "$ip"
done

echo
echo "Press Ctrl+C to stop and clean up."

sleep infinity