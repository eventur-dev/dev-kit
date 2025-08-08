#!/bin/bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

export PROJECT_ROOT="$ROOT_DIR"
export COMPOSE_FILE="$ROOT_DIR/.dev-kit/docker/compose.base.yml:$ROOT_DIR/docker-compose.yml"
export COMPOSE_PROJECT_NAME="${COMPOSE_PROJECT_NAME:-$(basename "$ROOT_DIR")}"
