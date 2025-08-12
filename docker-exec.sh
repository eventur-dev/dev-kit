#!/usr/bin/env bash
set -euo pipefail
. .dev-kit/docker_compose.sh

SERVICE="${SERVICE:-component}"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INNER_DIR="${ROOT_DIR}/.dev-kit/inner"

show_help() {
    echo "Usage: $0 <script_name> [arguments...]"
    echo
    echo "Runs a script from the .dev-kit/inner/ directory *inside* the container."
    echo "Service: ${SERVICE}   (override with SERVICE=...)"
    echo
    echo "Available scripts:"
    ls -1 "${INNER_DIR}"/*.sh 2>/dev/null | xargs -n1 basename || true
    exit 1
}

if [[ $# -lt 1 ]]; then
    show_help
fi

SCRIPT_NAME="$1"
shift

[[ "$SCRIPT_NAME" == *.sh ]] || SCRIPT_NAME="${SCRIPT_NAME}.sh"
HOST_SCRIPT_PATH="${INNER_DIR}/${SCRIPT_NAME}"

if ! compose ps -q "${SERVICE}" >/dev/null; then
    echo "❌ Service '${SERVICE}' is not running. Start it first: .dev-kit/docker-build.sh or: compose up -d ${SERVICE}"
    exit 1
fi

if [[ ! -f "$HOST_SCRIPT_PATH" ]]; then
    echo "❌ Script '${HOST_SCRIPT_PATH}' does not exist on host."
    show_help
fi

compose exec -T "${SERVICE}" bash -s -- "$@" < "${HOST_SCRIPT_PATH}"
