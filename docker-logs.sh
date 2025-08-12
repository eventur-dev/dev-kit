#!/usr/bin/env bash
set -euo pipefail
. .dev-kit/docker_compose.sh

compose logs -f
