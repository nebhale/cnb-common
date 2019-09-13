#!/usr/bin/env bash

set -euo pipefail

if [[ -d $PWD/go-module-cache && ! -d ${GOPATH}/pkg/mod ]]; then
  mkdir -p ${GOPATH}/pkg
  ln -s $PWD/go-module-cache ${GOPATH}/pkg/mod
fi

sha256() {
  cat "../dependency/sha256"
}

uri() {
  cat "../dependency/uri"
}

version() {
  cat "../dependency/version"
}


cd "$(dirname "${BASH_SOURCE[0]}")/../source"
[ -f "scripts/update-dependency.sh" ] && source "scripts/update-dependency.sh"

go build -ldflags='-s -w' -o bin/dependency github.com/cloudfoundry/libcfbuildpack/dependency
bin/dependency \
  "${DEPENDENCY}" \
  "[\d]+\.[\d]+(?:\.[\d]+)?" \
  "$(version)" \
  "$(uri)" \
  "$(sha256)"

git \
  -c user.name='Pivotal Java Experience Team' \
  -c user.email='cfje@pivotal.io' \
  commit \
  --signoff \
  --all \
  --message "Dependency Upgrade: ${DEPENDENCY} $(version)"
