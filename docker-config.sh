#!/usr/bin/env bash
set -euo pipefail

RAW=0
if [[ "${1:-}" == "--raw" ]]; then
  RAW=1
fi

. .dev-kit/docker_compose.sh

if [[ "$RAW" -eq 1 ]]; then
  compose config --no-interpolate
else
  compose config
fi
