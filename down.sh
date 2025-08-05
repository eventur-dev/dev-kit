#!/bin/bash
set -e

docker compose down --rmi local --volumes --remove-orphans
