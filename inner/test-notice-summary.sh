#!/usr/bin/env bash
set -euo pipefail

# --------------------------------------------------
# Colors (forced, safe)
# --------------------------------------------------
RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[1;33m'
BLUE=$'\033[0;34m'
CYAN=$'\033[0;36m'
GRAY=$'\033[0;90m'
BOLD=$'\033[1m'
RESET=$'\033[0m'

# --------------------------------------------------
# Args
# --------------------------------------------------
if [[ $# -ne 1 ]]; then
  echo "Usage: phpunit-summary <test-suite>"
  exit 1
fi

SUITE="$1"

# --------------------------------------------------
# Resolve repo root
# --------------------------------------------------
ROOT_DIR="$(pwd)"
while [[ "$ROOT_DIR" != "/" && ! -f "$ROOT_DIR/composer.json" ]]; do
  ROOT_DIR="$(dirname "$ROOT_DIR")"
done

PHPUNIT="$ROOT_DIR/vendor/bin/phpunit"
CONFIG="$ROOT_DIR/phpunit.dist.xml"

# --------------------------------------------------
# Header
# --------------------------------------------------
echo -e "${BOLD}${BLUE}▶ Eventur test notices${RESET}"
echo -e "${GRAY}--------------------------------------------------${RESET}"
echo -e "${CYAN}Suite:${RESET} ${BOLD}${SUITE}${RESET}"
echo -e "${GRAY}--------------------------------------------------${RESET}"
echo

# --------------------------------------------------
# Run PHPUnit in DEBUG (only way to get notice text)
# --------------------------------------------------
export EVENTUR_TEST_SUMMARY=1
export XDEBUG_MODE=off

TMP_OUT="$(mktemp)"
START_TS="$(date +%s%3N)"

set +e
"$PHPUNIT" \
  --configuration "$CONFIG" \
  --testsuite "$SUITE" \
  --debug \
  --colors=never \
  >"$TMP_OUT" 2>&1
EXIT_CODE=$?
set -e

END_TS="$(date +%s%3N)"
DURATION=$((END_TS - START_TS))

if [[ $EXIT_CODE -ne 0 ]]; then
  echo
  echo -e "${RED}✖ Tests failed${RESET}"
  cat "$TMP_OUT"
  rm -f "$TMP_OUT"
  exit "$EXIT_CODE"
fi

# --------------------------------------------------
# Extract + group notices
# --------------------------------------------------
declare -A SEEN
INDEX=1

while IFS= read -r line; do
  if [[ "$line" == *"Test Triggered PHPUnit Notice"* ]]; then
    read -r msg || true

    # normalize key (remove test name)
    KEY="$(echo "$msg" | sed 's/  */ /g')"

    if [[ -z "${SEEN[$KEY]:-}" ]]; then
      SEEN[$KEY]=1
      echo -e "${YELLOW}${INDEX}.${RESET} ${msg}"
      ((INDEX++))
    fi
  fi
done < "$TMP_OUT"

echo
echo -e "${GRAY}--------------------------------------------------${RESET}"

if [[ $INDEX -eq 1 ]]; then
  echo -e "${GREEN}✔ Tests OK${RESET}  ${YELLOW}⏱ ${DURATION} ms${RESET}"
  echo -e "${GRAY}No PHPUnit notices were emitted.${RESET}"
else
  echo -e "${GREEN}✔ Tests OK${RESET}  ${YELLOW}⏱ ${DURATION} ms${RESET}  ${CYAN}Notices: $((INDEX-1))${RESET}"
fi

rm -f "$TMP_OUT"
