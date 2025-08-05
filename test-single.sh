#!/bin/bash
set -e

php -d memory_limit=-1 vendor/bin/phpunit --testdox --colors=always --fail-on-warning --display-deprecations --filter "$@"
