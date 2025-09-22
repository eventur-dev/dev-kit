#!/bin/bash
set -e

vendor/bin/rector process --no-progress-bar --ansi --clear-cache
