#!/bin/bash
set -e

.dev-kit/git-safe-dir.sh
composer validate --strict
