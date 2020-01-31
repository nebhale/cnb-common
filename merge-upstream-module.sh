#!/usr/bin/env bash

set -euo pipefail
source common.sh







cd "${ROOT}/source"

git remote add upstream ../upstream
git fetch upstream --no-tags

set +e
git \
  -c user.name='Pivotal Java Experience Team' \
  -c user.email='cfje@pivotal.io' \
  merge \
  --log \
  --no-commit \
  --no-ff \
  $(cat ../upstream/.git/ref)

STATUS=$?
set -e

if [ $STATUS -ne 0 ]; then
  git checkout HEAD -- go.mod go.sum

  rm go.sum
  GOPRIVATE=* go get -u all
  go mod tidy

  git add go.mod go.sum
fi

git \
  -c user.name='Pivotal Java Experience Team' \
  -c user.email='cfje@pivotal.io' \
  commit \
  --no-edit
