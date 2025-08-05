#!/bin/bash
set -e

.dev-kit/git-safe-dir.sh
composer install --no-interaction --prefer-dist
