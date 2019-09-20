#!/usr/bin/env bash

set -euo pipefail

if [[ -d $PWD/go-module-cache && ! -d ${GOPATH}/pkg/mod ]]; then
  mkdir -p ${GOPATH}/pkg
  ln -s $PWD/go-module-cache ${GOPATH}/pkg/mod
fi

if [[ ! -d ${HOME}/.netrc ]]; then
  mkdir -p ${HOME}
  echo "machine github.com
login ${USERNAME}
password ${PASSWORD}" > ${HOME}/.netrc
fi

cd "$(dirname "${BASH_SOURCE[0]}")/../source"

[[ -z "$(find . -name "*.go")" ]] && exit

go test ./...
