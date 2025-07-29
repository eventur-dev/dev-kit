#!/bin/bash
set -e
php -d memory_limit=-1 vendor/bin/phpunit --migrate-configuration
