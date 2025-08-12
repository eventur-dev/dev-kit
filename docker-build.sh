#!/usr/bin/env bash
set -euo pipefail
. .dev-kit/docker_compose.sh

SERVICE="${SERVICE:-component}"

compose build devkit
compose build "${SERVICE}"
compose up -d "${SERVICE}"
