#!/usr/bin/env bash
set -euo pipefail

name="${1:-World}"

printf 'Hello, %s!\n' "$name"