#!/usr/bin/env bash
set -euo pipefail
. .dev-kit/docker_compose.sh

SERVICE="${SERVICE:-component}"

show_help() {
    echo "Usage: $0 <script_name> [arguments...]"
    echo
    echo "Runs a script from the .dev-kit/inner/ directory inside the container."
    echo "Service: ${SERVICE}   (override with SERVICE=...)"
    echo
    echo "Available scripts:"
    compose exec "${SERVICE}" bash -c "ls -1 /back-off/.dev-kit/inner/*.sh 2>/dev/null | xargs -n1 basename || true"
    exit 1
}

if [[ $# -lt 1 ]]; then
    show_help
fi

SCRIPT_NAME="$1"
shift

[[ "$SCRIPT_NAME" == *.sh ]] || SCRIPT_NAME="${SCRIPT_NAME}.sh"
SCRIPT_PATH="/back-off/.dev-kit/inner/${SCRIPT_NAME}"

if ! compose ps -q "${SERVICE}" >/dev/null; then
    echo "❌ Service '${SERVICE}' is not running. Start it first: .dev-kit/docker-build.sh or: compose up -d ${SERVICE}"
    exit 1
fi

if ! compose exec "${SERVICE}" test -f "$SCRIPT_PATH"; then
    echo "❌ Script '${SCRIPT_PATH}' does not exist in the container."
    show_help
fi

compose exec "${SERVICE}" chmod +x "$SCRIPT_PATH"
compose exec "${SERVICE}" "$SCRIPT_PATH" "$@"
