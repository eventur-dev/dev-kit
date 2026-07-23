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
  printf "Usage: phpunit-summary <test-suite>\n"
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
printf "%b▶ Eventur test notices%b\n" "$BOLD$BLUE" "$RESET"
printf "%b--------------------------------------------------%b\n" "$GRAY" "$RESET"
printf "%bSuite:%b %b%s%b\n" "$CYAN" "$RESET" "$BOLD" "$SUITE" "$RESET"
printf "%b--------------------------------------------------%b\n\n" "$GRAY" "$RESET"

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
  printf "\n%b✖ Tests failed%b\n" "$RED" "$RESET"
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
    # Extract test context
    # Example:
    # Test Triggered PHPUnit Notice (Foo\Bar\Test::testSomething)
    TEST_CTX="$(printf "%s\n" "$line" | sed -n 's/.*Notice (\(.*\))/\1/p')"

    # Next line is the notice message
    read -r msg || true
    MSG="$(printf "%s\n" "$msg" | sed 's/  */ /g')"

    KEY="$TEST_CTX|$MSG"

    if [[ -z "${SEEN[$KEY]:-}" ]]; then
      SEEN[$KEY]=1

      # Index + test
      printf "%b%d.%b %b%s%b\n" \
        "$YELLOW" "$INDEX" "$RESET" \
        "$BOLD" "$TEST_CTX" "$RESET"

      # Arrow + message (NO echo -e!)
      printf "   %b↳%b %s\n" "$GRAY" "$RESET" "$MSG"

      ((INDEX++))
    fi
  fi
done < "$TMP_OUT"

printf "\n%b--------------------------------------------------%b\n" "$GRAY" "$RESET"

if [[ $INDEX -eq 1 ]]; then
  printf "%b✔ Tests OK%b  %b⏱ %d ms%b\n" "$GREEN" "$RESET" "$YELLOW" "$DURATION" "$RESET"
  printf "%bNo PHPUnit notices were emitted.%b\n" "$GRAY" "$RESET"
else
  printf "%b✔ Tests OK%b  %b⏱ %d ms%b  %bNotices: %d%b\n" \
    "$GREEN" "$RESET" \
    "$YELLOW" "$DURATION" "$RESET" \
    "$CYAN" "$((INDEX-1))" "$RESET"
fi

rm -f "$TMP_OUT"
