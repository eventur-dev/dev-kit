#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/compose.sh"

BASE="$PROJECT_ROOT/.dev-kit/docker/compose.base.yml"
LOCAL="$PROJECT_ROOT/docker-compose.yml"

[[ -f "$BASE" ]]  || { echo "❌ Missing $BASE";  exit 1; }
[[ -f "$LOCAL" ]] || { echo "❌ Missing $LOCAL"; exit 1; }

echo "ℹ️ Using COMPOSE_FILE=$COMPOSE_FILE"
echo "ℹ️ Using PROJECT_ROOT=$PROJECT_ROOT"

docker compose config | sed -n '1,160p'

docker compose up -d --build
