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
# Extract + group notices (WITH test context)
# --------------------------------------------------
declare -A SEEN
INDEX=1

while IFS= read -r line; do
  if [[ "$line" == *"Test Triggered PHPUnit Notice"* ]]; then
    # extract test name
    # Example:
    # Test Triggered PHPUnit Notice (Foo\Bar\Test::testSomething)
    TEST_CTX="$(echo "$line" | sed -n 's/.*Notice (\(.*\))/\1/p')"

    # next line is the notice message
    read -r msg || true

    # normalize message
    MSG="$(echo "$msg" | sed 's/  */ /g')"

    KEY="$TEST_CTX|$MSG"

    if [[ -z "${SEEN[$KEY]:-}" ]]; then
      SEEN[$KEY]=1
      echo -e "${YELLOW}${INDEX}.${RESET} ${BOLD}${TEST_CTX}${RESET}"
      echo -e "   ${GRAY}↳${RESET} ${MSG}"
      ((INDEX++))
    fi
  fi
done < "$TMP_OUT"
