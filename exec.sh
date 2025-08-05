#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SERVICE_FILE="$SCRIPT_DIR/../.service"

SERVICE="${SERVICE:-}"
if [[ -z "$SERVICE" ]]; then
    if [[ -f "$SERVICE_FILE" ]]; then
        SERVICE="$(<"$SERVICE_FILE")"
    else
        echo "❌ SERVICE not set and no .service file found" >&2
        exit 1
    fi
fi

if [[ "${1:-}" == "help" ]]; then
    find "$SCRIPT_DIR" -maxdepth 1 -type f -name '*.sh' ! -name 'exec.sh' \
        -exec basename {} .sh \; | sort
    echo
    echo "Usage:"
    echo "  $0 <script_name> [args...]   # run script inside container (SERVICE=$SERVICE)"
    echo "  SERVICE=name $0 ...          # override service"
    echo "  $0                           # enter the container shell"
    exit 0
fi

if [[ $# -eq 0 ]]; then
    docker compose exec "$SERVICE" bash
    exit 0
fi

SCRIPT_NAME="${1%.sh}"
shift

ESCAPED_ARGS=()
for arg in "$@"; do
  ESCAPED_ARGS+=("$(printf '%q' "$arg")")
done

docker compose exec "$SERVICE" bash -c "/.dev-kit/${SCRIPT_NAME}.sh ${ESCAPED_ARGS[*]}"
