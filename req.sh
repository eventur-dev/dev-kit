#!/bin/bash
set -e

.dev-kit/git-safe-dir.sh
composer require "$@"
