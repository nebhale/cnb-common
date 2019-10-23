#!/usr/bin/env bash

set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/../source"

git remote add upstream ../upstream
git fetch upstream --no-tags

git \
  -c user.name='Pivotal Java Experience Team' \
  -c user.email='cfje@pivotal.io' \
  merge \
  --log \
  --no-commit \
  --no-ff \
  $(cat ../upstream/.git/ref)

git checkout HEAD -- go.mod go.sum

rm go.sum
GOPRIVATE=* go get -u all
go mod tidy

git add go.mod go.sum

git \
  -c user.name='Pivotal Java Experience Team' \
  -c user.email='cfje@pivotal.io' \
  commit \
  --no-edit
