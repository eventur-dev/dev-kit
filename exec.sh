#!/bin/bash
set -euo pipefail
source .dev-kit/compose.sh

SERVICE="app"

if [[ "${1:-}" == "help" ]]; then
    find .dev-kit -maxdepth 1 -type f -name '*.sh' ! -name 'exec.sh' \
        -exec basename {} .sh \; | sort
    echo
    echo "Usage:"
    echo "  $0 <script_name> [args...]   # run script inside container (SERVICE=$SERVICE)"
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
