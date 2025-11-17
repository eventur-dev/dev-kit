#!/usr/bin/env bash
set -euo pipefail
. .dev-kit/docker_compose.sh

# The main PHP service that every library needs
MAIN_SERVICE="component"

# Optional file with additional services required by the library
SERVICES_FILE=".services"
EXTRA_SERVICES=()

# Load extra services if the file exists
if [[ -f "$SERVICES_FILE" ]]; then
    echo "📄 Found $SERVICES_FILE – loading additional services"
    mapfile -t EXTRA_SERVICES < "$SERVICES_FILE"
fi

# List of services to start (main + extra)
SERVICES=("$MAIN_SERVICE" "${EXTRA_SERVICES[@]}")

echo "🚀 Starting services: ${SERVICES[*]}"

# Start all required services
compose up -d "${SERVICES[@]}"
