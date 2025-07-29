#!/bin/bash
set -e
php -d memory_limit=-1 vendor/bin/phpunit \
  --testdox \
  --colors=never \
  --coverage-text \
  --display-deprecations \
  --fail-on-incomplete \
  --fail-on-risky \
  --fail-on-skipped \
  --fail-on-warning \
| tee /tmp/coverage.out

grep 'Lines:   100.00%' /tmp/coverage.out > /dev/null || {
    echo -e '\n\033[0;31m❌ Code coverage is below 100%.\033[0m\n'
    exit 1
}
