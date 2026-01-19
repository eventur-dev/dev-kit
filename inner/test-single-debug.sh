#!/bin/bash
set -e

export XDEBUG_MODE=debug

php -d memory_limit=-1 \
    -d xdebug.start_with_request=yes \
    vendor/bin/phpunit \
    --testdox \
    --colors=always \
    --fail-on-warning \
    --display-deprecations \
    --filter "$@"
