#!/usr/bin/env bash
set -euo pipefail

if [[ $# -gt 0 ]]; then
  echo "🔄 Updating selected packages: $*"
  composer update "$@" --ansi
else
  echo "🔄 Updating all packages..."
  composer update --ansi
fi

echo "✅ Update complete."
