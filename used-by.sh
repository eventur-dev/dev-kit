#!/usr/bin/env bash
set -euo pipefail

CURRENT_PACKAGE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ROOT_DIR="$(cd "$CURRENT_PACKAGE_DIR/.." && pwd)"
CURRENT_PACKAGE_NAME=$(jq -r '.name' "$CURRENT_PACKAGE_DIR/composer.json")

echo "🔍 Searching for packages that depend on: $CURRENT_PACKAGE_NAME"
echo "📦 Scanning in: $ROOT_DIR"
echo

TMP_FILE="$(mktemp)"

find "$ROOT_DIR" -mindepth 2 -maxdepth 2 -type f -name composer.json | while read -r json_file; do
    package_dir=$(dirname "$json_file")
    package_name=$(basename "$package_dir")

    if [ "$package_dir" = "$CURRENT_PACKAGE_DIR" ]; then
        continue
    fi

    location=$(jq -r --arg name "$CURRENT_PACKAGE_NAME" '
        if (.require[$name]? != null) then "require"
        elif (."require-dev"[$name]? != null) then "require-dev"
        else empty end
    ' "$json_file")

    if [ -n "$location" ]; then
        echo "✅ $package_name depends on $CURRENT_PACKAGE_NAME ($location)" | tee -a "$TMP_FILE"
    fi
done

if [ ! -s "$TMP_FILE" ]; then
    echo "❌ No packages found using $CURRENT_PACKAGE_NAME"
fi

rm -f "$TMP_FILE"
