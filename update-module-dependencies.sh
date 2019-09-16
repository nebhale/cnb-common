#!/usr/bin/env bash

set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/../source"

GOPRIVATE=* go get -u all
go mod tidy

git \
  -c user.name='Pivotal Java Experience Team' \
  -c user.email='cfje@pivotal.io' \
  commit \
  --signoff \
  --all \
  --message 'Go Module Update'
