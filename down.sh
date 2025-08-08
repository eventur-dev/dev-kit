#!/bin/bash
set -euo pipefail
source .dev-kit/compose.sh
docker compose down --rmi local --volumes --remove-orphans
