#!/bin/bash

mkdir -p docker/composer

cat <<EOF > docker/composer/auth.json
{
  "github-oauth": {
    "github.com": "${GITHUB_TOKEN}"
  }
}
EOF
