#!/usr/bin/env bash
set -euo pipefail

compose() {
  docker compose \
    --project-directory . \
    -f .dev-kit/docker/compose.base.yml \
    -f ./docker-compose.yml \
    "$@"
}
