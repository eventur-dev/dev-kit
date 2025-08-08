#!/bin/bash
set -euo pipefail
source .dev-kit/compose.sh
docker compose up -d --build
