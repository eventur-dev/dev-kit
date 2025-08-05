#!/bin/bash
set -e

PROJECT_ROOT=$(git rev-parse --show-toplevel)

HOME=/tmp git config --global --add safe.directory "$PROJECT_ROOT"
