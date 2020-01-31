#!/usr/bin/env bash

set -euo pipefail

if [[ -d $PWD/go-module-cache && ! -d ${GOPATH}/pkg/mod ]]; then
  mkdir -p ${GOPATH}/pkg
  ln -s $PWD/go-module-cache ${GOPATH}/pkg/mod
fi

cd "$(dirname "${BASH_SOURCE[0]}")/../source"

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
