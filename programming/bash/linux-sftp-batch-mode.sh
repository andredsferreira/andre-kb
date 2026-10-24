#!/usr/bin/env bash
set -euo pipefail

# Batch mode (-b flag) requires key based authentication (password will fail).

sftp -P 10282 -i ~/.ssh/id_rsa_debian13trixie01 -b - root@vsgate-ssh.dei.isep.ipp.pt << EOF
cd /srv/uploads
put app.war
EOF