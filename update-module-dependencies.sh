#!/usr/bin/env bash

set -euo pipefail

if [[ -d $PWD/go-module-cache && ! -d ${GOPATH}/pkg/mod ]]; then
  mkdir -p ${GOPATH}/pkg
  ln -s $PWD/go-module-cache ${GOPATH}/pkg/mod
fi

cd "$(dirname "${BASH_SOURCE[0]}")/../source"
go get -u all
go mod tidy
git commit --author="Pivotal Java Experience Team <cfje@pivotal.io>" -m "Go Module Update"
