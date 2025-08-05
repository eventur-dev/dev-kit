#!/bin/bash
set -e

vendor/bin/php-cs-fixer fix --dry-run --diff --allow-risky=yes
