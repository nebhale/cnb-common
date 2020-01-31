#!/usr/bin/env bash

set -euo pipefail
source $(dirname $0)/common.sh

cd "${ROOT}/source"

rm go.sum
GOPRIVATE=* go get -u all
go mod tidy

git add go.mod go.sum
git checkout -- .

git \
  -c user.name='Pivotal Java Experience Team' \
  -c user.email='cfje@pivotal.io' \
  commit \
  --signoff \
  --message 'Go Module Update' || true
