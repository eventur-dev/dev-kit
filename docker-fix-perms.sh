#!/usr/bin/env bash
set -euo pipefail
docker run --rm -v "$PWD":/work -w /work alpine:3.20 sh -c "chown -R ${UID:-1000}:${GID:-1000} ."
