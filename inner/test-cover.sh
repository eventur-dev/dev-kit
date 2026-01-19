#!/bin/bash
set -e

XDEBUG_MODE=coverage \
php -d memory_limit=-1 \
    vendor/bin/phpunit \
    --testdox \
    --colors=never \
    --fail-on-warning \
    --display-deprecations \
    --coverage-html coverage-report
